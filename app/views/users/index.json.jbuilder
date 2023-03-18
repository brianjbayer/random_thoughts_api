# frozen_string_literal: true

json.data @users, partial: 'user', as: :user, current_user: @current_user

json.partial! 'meta/meta', items: @users, total: User.count
