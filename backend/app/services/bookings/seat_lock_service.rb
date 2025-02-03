module Bookings
  # Atomic, all-or-nothing Redis seat lock implemented via a Lua script so that
  # two concurrent users can never both lock the same seat for the same show.
  #
  # Key layout:
  #   seat_lock:{show_id}:{seat_id}        -> "{user_id}:{lock_token}"
  #   seat_lock_index:{show_id}            -> SET of locked seat ids (for cheap reads)
  class SeatLockService
    LOCK_TTL = (ENV.fetch('SEAT_LOCK_TTL_SECONDS', 300).to_i).seconds

    LOCK_SCRIPT = <<~LUA.freeze
      local n = tonumber(ARGV[1])
      local value = ARGV[2]
      local ttl = tonumber(ARGV[3])
      local index_key = ARGV[4]

      for i = 1, n do
        if redis.call('EXISTS', KEYS[i]) == 1 then
          return 0
        end
      end
      for i = 1, n do
        redis.call('SET', KEYS[i], value, 'EX', ttl)
      end
      redis.call('SADD', index_key, unpack(ARGV, 5, 4 + n))
      redis.call('EXPIRE', index_key, ttl + 60)
      return 1
    LUA

    RELEASE_SCRIPT = <<~LUA.freeze
      local index_key = ARGV[1]
      local expected = ARGV[2]
      for i, k in ipairs(KEYS) do
        local v = redis.call('GET', k)
        if v == expected then
          redis.call('DEL', k)
          redis.call('SREM', index_key, string.match(k, '[^:]+$'))
        end
      end
      return 1
    LUA

    Result = Struct.new(:lock_token, :expires_at, :show_id, :seat_ids, keyword_init: true)

    class << self
      def lock!(show_id:, seat_ids:, user_id:)
        raise ArgumentError, 'seat_ids cannot be empty' if seat_ids.blank?
        # also fail fast if any seat is already booked
        booked = ::BookingSeat.where(active: true, show_id: show_id, seat_id: seat_ids).pluck(:seat_id)
        raise Errors::SeatUnavailable.new(seat_ids: booked) if booked.any?

        lock_token = SecureRandom.uuid
        value      = "#{user_id}:#{lock_token}"
        keys       = seat_ids.map { |sid| seat_key(show_id, sid) }
        lock_index_key  = index_key(show_id)

        ok = REDIS.with do |r|
          r.eval(LOCK_SCRIPT, keys: keys, argv: [seat_ids.size.to_s, value, LOCK_TTL.to_i.to_s, lock_index_key, *seat_ids])
        end

        raise Errors::SeatUnavailable, 'Some seats are already locked' if ok.to_i.zero?

        ActionCable.server.broadcast(
          "seat_channel:#{show_id}",
          { event: 'seat_locked', seat_ids: seat_ids, user_id: user_id }
        )

        Result.new(
          lock_token: lock_token,
          expires_at: LOCK_TTL.from_now,
          show_id:    show_id,
          seat_ids:   seat_ids
        )
      end

      def verify!(show_id:, seat_ids:, user_id:, lock_token:)
        expected = "#{user_id}:#{lock_token}"
        REDIS.with do |r|
          seat_ids.each do |sid|
            value = r.get(seat_key(show_id, sid))
            raise Errors::LockExpired, "Lock expired for seat #{sid}" if value.nil?
            raise Errors::InvalidLockToken, "Invalid lock token for seat #{sid}" if value != expected
          end
        end
        true
      end

      def release!(show_id:, seat_ids:, user_id:, lock_token:)
        expected = "#{user_id}:#{lock_token}"
        keys = seat_ids.map { |sid| seat_key(show_id, sid) }
        REDIS.with do |r|
          r.eval(RELEASE_SCRIPT, keys: keys, argv: [index_key(show_id), expected])
        end
        ActionCable.server.broadcast(
          "seat_channel:#{show_id}",
          { event: 'seat_released', seat_ids: seat_ids }
        )
      end

      # Used by the seat-map endpoint and the sweeper job.
      def locked_seat_ids_for(show_id)
        REDIS.with { |r| r.smembers(index_key(show_id)) }
      end

      def prune_index!(show_id)
        REDIS.with do |r|
          members = r.smembers(index_key(show_id))
          alive   = members.select { |sid| r.exists?(seat_key(show_id, sid)).positive? }
          to_remove = members - alive
          r.srem(index_key(show_id), to_remove) if to_remove.any?
          to_remove
        end
      end

      private

      def seat_key(show_id, seat_id);  "seat_lock:#{show_id}:#{seat_id}"; end
      def index_key(show_id);          "seat_lock_index:#{show_id}";       end
    end
  end
end
