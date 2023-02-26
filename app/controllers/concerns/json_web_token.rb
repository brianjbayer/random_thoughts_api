# frozen_string_literal: true

# Module for handling encoding and ecoding of this application's JWTs
module JsonWebToken
  extend ActiveSupport::Concern
  JWT_SECRET = Rails.configuration.jwt_secret
  JWT_AUDIENCE = 'random_thoughts_api'

  included do
    def jwt_encode(payload, issuer = default_issuer, expiration = 1.day.from_now)
      payload[:aud] = JWT_AUDIENCE
      payload[:iss] = issuer
      payload[:exp] = expiration.to_i

      JWT.encode(payload, JWT_SECRET, 'HS256')
    end

    def jwt_decode(token, issuer = default_issuer)
      # TODO: add expired token handling - throws JWT::ExpiredSignature
      decoded_token = JWT.decode(token, JWT_SECRET, true, {
                                   # Verify issuer - throws JWT::InvalidIssuerError
                                   iss: issuer, verify_iss: true,
                                   # Verify audience throws JWT::InvalidAudError
                                   aud: JWT_AUDIENCE, verify_aud: true,
                                   algorithm: 'HS256'
                                 })
      ActiveSupport::HashWithIndifferentAccess.new(decoded_token)
    end
  end

  private

  def default_issuer
    'random_thoughts_api'
  end
end
