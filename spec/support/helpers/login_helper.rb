# frozen_string_literal: true

module LoginHelper
  def build_login_body(user)
    body = user.attributes.slice('email')
    # NOTE: password attributes must be handled explicitly
    body['password'] = user.password
    { authentication: body }
  end
end
