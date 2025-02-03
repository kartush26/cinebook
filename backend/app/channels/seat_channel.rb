class SeatChannel < ApplicationCable::Channel
  def subscribed
    show = Show.find_by(id: params[:show_id])
    return reject if show.nil?

    stream_from "seat_channel:#{show.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
