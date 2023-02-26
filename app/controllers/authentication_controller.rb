# frozen_string_literal: true

# Implements application authentication actions
class AuthenticationController < ApplicationController
  include JsonWebToken

  # Post /authentication/login
  def login
    @user = User.find_by(email: params[:authentication][:email])
    if @user&.authenticate(params[:authentication][:password])
      token = jwt_encode({ user: @user.id }, 'authentication')
      logger.info "Login: Authenticated user [#{@user.email}]"
      render_logged_in(token)
    else
      render_error_response(:unauthorized, 'Invalid login')
    end
  end

  private

  def render_logged_in(token)
    render status: :ok, json: {
      message: 'User logged in successfully',
      token:
    }
  end
end
