# frozen_string_literal: true

module Authorization
  module Errors
    class AuthorizationError < StandardError; end

    # Custom exception for revoked authorization token (JWT)
    class TokenRevokedError < AuthorizationError
      def initialize
        super('Unauthorized: User logged out or access revoked')
      end
    end
  end
end
