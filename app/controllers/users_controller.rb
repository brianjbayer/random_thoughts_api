# frozen_string_literal: true

# Implements CRUD operations for User
class UsersController < ApplicationController
  include AuthorizeUserConcern
  include RenderResponseConcern

  before_action :authorize_request, only: %i[show]
  before_action :find_user, only: %i[show]

  def show
    # before_actions and show view
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render status: :created
    else
      # NOTE: Bad Requests are handled by error handler
      render_validation_error_response(@user)
    end
  end

  private

  def user_params
    params.require(:user).permit(:email,
                                 :display_name,
                                 :password,
                                 :password_confirmation)
  end

  def find_user
    @user = User.find(params[:id])
  end
end
