# frozen_string_literal: true

# Module to assist in tests that require authorization with JSON Web Tokens
module JwtHelper
  include Authorization::JsonWebToken

  def auth_value(jwt)
    decode_authentication_jwt(jwt)['auth']
  end

  def authorization_header(token)
    { 'Authorization' => "Bearer #{token}" }
  end

  def valid_jwt(user)
    authentication_jwt(app_payload(user))
  end

  def invalid_algorithm_jwt(user)
    jwt_encode(valid_authentication_payload(app_payload(user)), algorithm: 'none')
  end

  def invalid_signature_jwt(user)
    jwt_encode(valid_authentication_payload(app_payload(user)), secret: 'not-the-encoded-secret')
  end

  def invalid_audience_jwt(user)
    jwt_encode(invalid_payload(user, :aud, 'INVALID'))
  end

  def invalid_issuer_jwt(user)
    jwt_encode(invalid_payload(user, :iss, 'INVALID'))
  end

  def expired_jwt(user)
    jwt_encode(invalid_payload(user, :exp, 1.second.ago.to_i))
  end

  def missing_user_claim_jwt(user)
    authentication_jwt(app_payload(user, id: false))
  end

  def missing_auth_claim_jwt(user)
    authentication_jwt(app_payload(user, auth: false))
  end

  private

  def invalid_payload(user, key, value)
    bad_payload = valid_authentication_payload(app_payload(user))
    bad_payload[key] = value
    bad_payload
  end

  def app_payload(user, id: true, auth: true)
    payload = {}
    payload[:user] = user.id if id
    payload[:auth] = user.authorization_min if auth
    payload
  end
end
