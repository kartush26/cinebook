require 'sidekiq'

# Defensive sweeper. The Redis SET tracking locked seats per show can drift
# (Lua failures, manual deletes) — this prunes orphans and broadcasts
# `seat_released` for any seats that no longer have a live lock.
class ReleaseExpiredLocksJob
  include Sidekiq::Job
  sidekiq_options queue: 'low', retry: 3

  def perform
    Show.upcoming.find_each do |show|
      removed = Bookings::SeatLockService.prune_index!(show.id)
      next if removed.empty?

      ActionCable.server.broadcast(
        "seat_channel:#{show.id}",
        { event: 'seat_released', seat_ids: removed }
      )
    end
  end
end
