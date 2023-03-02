# frozen_string_literal: true

# Implements application authentication actions
class AuthenticationController < ApplicationController
  include Authorization::JsonWebToken
  include AuthorizeUserConcern

  before_action :authorize_request, only: %i[logout]

  # Post /authentication/login
  def login
    @user = User.find_by(email: params[:authentication][:email])
    if @user&.authenticate(params[:authentication][:password])
      token = authentication_jwt(app_payload(@user))
      logger.info "Login: Authenticated user [#{@user.email}]"
      render_logged_in(token)
    else
      render_error_response(:unauthorized, 'Invalid login')
    end
  end

  def logout
    @current_user.revoke_auth
    logger.info "Logout: Logged out user [#{@current_user.email}]"
    render status: :ok, json: { message: 'User logged out successfully' }
  end

  private

  def render_logged_in(token)
    render status: :ok, json: {
      message: 'User logged in successfully',
      token:
    }
  end

  def app_payload(user)
    {
      user: user.id,
      auth: user.authorization_min
    }
  end
end
