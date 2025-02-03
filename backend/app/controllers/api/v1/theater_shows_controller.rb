module API
  module V1
    class TheaterShowsController < ApplicationController
      skip_before_action :authenticate_user!

      def index
        shows = Show.upcoming
                    .for_theater(params[:theater_id])
                    .for_movie(params[:movie_id])
                    .on_date(params[:date])
                    .includes(:movie, screen: :theater)
                    .order(:starts_at)
                    .page(params[:page]).per(params[:per_page] || 100)
        render_success(ShowSerializer.render_as_hash(shows), meta: pagination_meta(shows))
      end
    end
  end
end
