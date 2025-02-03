module API
  module V1
    class TheatersController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[index show]

      def index
        scope = Theater.active.in_city(params[:city]).order(:name)
                       .page(params[:page]).per(params[:per_page] || 30)
        render_success(TheaterSerializer.render_as_hash(scope), meta: pagination_meta(scope))
      end

      def show
        theater = Theater.includes(:screens).find(params[:id])
        render_success(TheaterSerializer.render_as_hash(theater, view: :detail))
      end
    end
  end
end
