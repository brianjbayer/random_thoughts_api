# frozen_string_literal: true

module UserHelper
  def build_user_body(user)
    body = user.attributes.slice('email', 'display_name')
    # NOTE: password attributes must be handled explicitly
    body['password'] = user.password
    body['password_confirmation'] = user.password_confirmation
    { user: body }
  end
end
