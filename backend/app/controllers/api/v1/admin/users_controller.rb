module API
  module V1
    module Admin
      class UsersController < ApplicationController
        def index
          scope = User.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 25)
          render_success(UserSerializer.render_as_hash(scope), meta: pagination_meta(scope))
        end

        def update
          user = User.find(params[:id])
          user.update!(user_params)
          render_success(UserSerializer.render_as_hash(user))
        end

        def destroy
          User.find(params[:id]).update!(active: false)
          head :no_content
        end

        private

        def user_params
          params.require(:user).permit(:active, :role, :name, :phone)
        end
      end
    end
  end
end
