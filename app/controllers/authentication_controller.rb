# frozen_string_literal: true

# Implements application authentication actions
class AuthenticationController < ApplicationController
  # Post /authentication/login
  def login
    @user = User.find_by(email: params[:authentication][:email])
    if @user&.authenticate(params[:authentication][:password])
      # TODO: For now just log successful login and return 200
      logger.info "Login: Authenticated user [#{@user.email}]"
      render status: :ok, json: {
        message: 'Successfully logged in user',
        token: 'TODO: return JWT'
      }
    else
      render_error_response(:unauthorized, 'Invalid login')
    end
  end
end
