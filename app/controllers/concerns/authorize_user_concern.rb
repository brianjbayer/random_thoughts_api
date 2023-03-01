# frozen_string_literal: true

# Module for Authorizing a user from JWT in request header
module AuthorizeUserConcern
  extend ActiveSupport::Concern
  include Authorization::JsonWebToken

  included do
    def authorize_request
      decoded_jwt = decode_authentication_jwt(request_authorization_token)
      @current_user = User.find(decoded_jwt['user'])
    end
  end

  private

  def request_authorization_token
    header = request.headers['Authorization']
    header&.split&.last
  end
end
