# frozen_string_literal: true

module UserHelper
  def build_user_body(user)
    # We build this explicitly (vs. as_json) to populate password* attributes
    {
      user: {
        email: user.email,
        display_name: user.display_name,
        password: user.password,
        password_confirmation: user.password_confirmation
      }
    }
  end
end
