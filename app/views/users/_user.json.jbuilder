# frozen_string_literal: true

# json.call(user, :id, :email, :display_name)
if current_user == user
  json.id user.id
  json.email user.email
end
json.display_name user.display_name
