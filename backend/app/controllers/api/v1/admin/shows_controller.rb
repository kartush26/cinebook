module API
  module V1
    module Admin
      class ShowsController < ApplicationController
        def index
          scope = Show.includes(:movie, screen: :theater)
                      .order(starts_at: :desc)
                      .page(params[:page]).per(params[:per_page] || 25)
          render_success(ShowSerializer.render_as_hash(scope), meta: pagination_meta(scope))
        end

        def show
          render_success(ShowSerializer.render_as_hash(Show.includes(screen: :theater).find(params[:id])))
        end

        def create
          show = Show.create!(show_params.merge(ends_at: compute_ends_at))
          render_success(ShowSerializer.render_as_hash(show), status: :created)
        end

        def update
          show = Show.find(params[:id])
          show.update!(show_params.merge(ends_at: compute_ends_at(show)))
          render_success(ShowSerializer.render_as_hash(show))
        end

        def destroy
          Show.find(params[:id]).update!(status: :cancelled)
          head :no_content
        end

        private

        def show_params
          params.require(:show).permit(:movie_id, :screen_id, :starts_at, :price_multiplier, :language, :status)
        end

        def compute_ends_at(existing = nil)
          starts_at = Time.zone.parse(show_params[:starts_at].to_s) if show_params[:starts_at].present?
          starts_at ||= existing&.starts_at
          duration = Movie.find(show_params[:movie_id] || existing&.movie_id).duration_minutes
          starts_at + duration.minutes
        end
      end
    end
  end
end
