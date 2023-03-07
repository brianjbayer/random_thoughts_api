# frozen_string_literal: true

module UserHelper
  def build_user_body(user)
    user_body = user.attributes.slice('email', 'display_name')
    # NOTE: password attributes must be handled explicitly
    user_body['password'] = user.password
    user_body['password_confirmation'] = user.password_confirmation
    { user: user_body }
  end
end
