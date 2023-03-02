# frozen_string_literal: true

# Module for Authorizing a user from JWT in request header
module AuthorizeUserConcern
  extend ActiveSupport::Concern
  include Authorization::JsonWebToken
  include Authorization::Errors

  included do
    def authorize_request
      decoded_jwt = decode_authentication_jwt(request_authorization_token)
      @current_user = User.find(decoded_jwt['user'])
      validate_token(@current_user, decoded_jwt)
    end
  end

  private

  def request_authorization_token
    header = request.headers['Authorization']
    header&.split&.last
  end

  def validate_token(user, token)
    raise Authorization::Errors::TokenRevokedError if user.auth_revoked?(token['auth'])
  end
end
