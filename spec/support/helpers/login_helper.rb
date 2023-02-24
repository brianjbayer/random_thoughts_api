# frozen_string_literal: true

module LoginHelper
  def build_login_body(user)
    # We build this explicitly (vs. as_json) to populate password* attributes
    {
      authentication: {
        email: user.email,
        password: user.password
      }
    }
  end
end
