# frozen_string_literal: true

# Implements CRUD operations for User
class UsersController < ApplicationController
  before_action :authorize_request, only: %i[index show update destroy]
  before_action :find_user, only: %i[show update destroy]
  before_action :authorize_current_user, only: %i[update destroy]

  def index
    @users = User.page(params[:page])
  end

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

  def update
    if @user.update(user_params)
      render_show_response(:ok)
    else
      # NOTE: Bad Requests are handled by error handler
      render_validation_error_response(@user)
    end
  end

  def destroy
    @user.destroy!
    render_show_response(:ok)
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
