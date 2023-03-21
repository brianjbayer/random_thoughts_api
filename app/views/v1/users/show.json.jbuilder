# frozen_string_literal: true

json.partial! @user, partial: 'user', as: :user, current_user: @current_user
