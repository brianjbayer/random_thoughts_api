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

    # Custom exception when user is not authorized for action
    # (i.e. id is not current user's id)
    class UnauthorizedUserError < AuthorizationError
      def initialize
        super('Unauthorized: User does not authorization for this action')
      end
    end

    # Custom exception when user record has been deleted
    class DeletedUserError < AuthorizationError
      def initialize
        super('Unauthorized: User has been deleted')
      end
    end
  end
end
