# frozen_string_literal: true

if current_user == user
  json.id user.id
  json.email user.email
end
json.display_name user.display_name
