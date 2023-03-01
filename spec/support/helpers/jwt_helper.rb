# frozen_string_literal: true

# Module to assist in tests that require authorization with JSON Web Tokens
module JwtHelper
  include Authorization::JsonWebToken

  def authorization_header(token)
    { 'Authorization' => "Bearer #{token}" }
  end

  def valid_jwt(id)
    authentication_jwt(app_payload(id))
  end

  def invalid_algorithm_jwt(id)
    jwt_encode(valid_authentication_payload(app_payload(id)), algorithm: 'none')
  end

  def invalid_signature_jwt(id)
    jwt_encode(valid_authentication_payload(app_payload(id)), secret: 'not-the-encoded-secret')
  end

  def invalid_audience_jwt(id)
    jwt_encode(invalid_payload(id, :aud, 'INVALID'))
  end

  def invalid_issuer_jwt(id)
    jwt_encode(invalid_payload(id, :iss, 'INVALID'))
  end

  def expired_jwt(id)
    jwt_encode(invalid_payload(id, :exp, 1.second.ago.to_i))
  end

  def missing_user_claim_jwt
    authentication_jwt({})
  end

  private

  def invalid_payload(id, key, value)
    bad_payload = valid_authentication_payload(app_payload(id))
    bad_payload[key] = value
    bad_payload
  end

  def app_payload(id)
    { user: id }
  end
end
