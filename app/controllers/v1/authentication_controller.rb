# frozen_string_literal: true

module V1
  # Implements application authentication actions
  # NOTE: The RESTful actions of create (POST) login
  # and DELETE login are mapped to the more intuitive
  # actions of login and logout
  class AuthenticationController < V1::ApplicationController
    include Authorization::JsonWebToken

    before_action :authorize_request, only: %i[logout]

    # POST /authentication/login
    def login
      @user = User.find_by(email: params[:authentication][:email])
      if @user&.authenticate(params[:authentication][:password])
        token = authentication_jwt(app_payload(@user))
        logger.info "Login: Authenticated user [#{@user.id} (#{@user.email})]"
        render_logged_in(token)
      else
        render_error_response(:unauthorized, 'Invalid login')
      end
    end

    # DELETE /authentication/login
    def logout
      @current_user.revoke_auth
      logger.info "Logout: Logged out user [#{@current_user.id} (#{@current_user.email})]"
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
end
