# frozen_string_literal: true

module Authorization
  # Module for handling this application's JWTs, encoding, decoding, and testing
  module JsonWebToken
    def valid_authentication_payload(payload)
      payload[:aud] = 'random_thoughts_api'
      payload[:iss] = 'authentication'
      payload[:exp] = 1.day.from_now.to_i
      payload
    end

    def authentication_jwt(payload)
      jwt_encode(valid_authentication_payload(payload))
    end

    def decode_authentication_jwt(token)
      jwt_decode(token, valid_authentication_payload({}))
    end

    def jwt_encode(payload, secret: valid_secret, algorithm: valid_algorithm)
      JWT.encode(payload, secret, algorithm)
    end

    def jwt_decode(token, expected_payload)
      issuer = expected_payload[:iss]
      audience = expected_payload[:aud]
      decoded = JWT.decode(token, valid_secret, true, {
                             required_claims:,
                             iss: issuer, verify_iss: true,
                             aud: audience, verify_aud: true,
                             algorithm: valid_algorithm
                           })
      ActiveSupport::HashWithIndifferentAccess.new(decoded.first)
    end

    private

    def required_claims
      %w[aud exp iss user auth]
    end

    def valid_secret
      Rails.configuration.jwt_secret
    end

    def valid_algorithm
      'HS256'
    end
  end
end
