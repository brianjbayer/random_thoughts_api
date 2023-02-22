# frozen_string_literal: true

# Implements CRUD operations for User
class UsersController < ApplicationController
  include RenderResponseConcern

  def create
    @user = User.create!(user_params)
    render_show_response(:created)
  end

  private

  def user_params
    params.require(:user).permit(:email,
                                 :display_name,
                                 :password,
                                 :password_confirmation)
  end
end
