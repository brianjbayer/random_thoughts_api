# frozen_string_literal: true

# Represents a user of this application
class User < ApplicationRecord
  PASSWORD_MIN_LENGTH = 8

  has_many :random_thoughts, dependent: :destroy

  default_scope -> { order(display_name: :asc) }, all_queries: true

  validates :email, presence: true, uniqueness: true,
                    # NOTE: citext (db) does not support max length constraint
                    length: {
                      # Max email address length is actually 254
                      # see https://www.rfc-editor.org/errata_search.php?rfc=3696&eid=1690
                      maximum: 254
                    },
                    format: {
                      with: URI::MailTo::EMAIL_REGEXP,
                      # rubocop:disable Rails/I18nLocaleTexts
                      # Currently assuming English language
                      message: 'must match URI::MailTo::EMAIL_REGEXP'
                      # rubocop:enable Rails/I18nLocaleTexts
                    }

  validates :display_name, presence: true

  has_secure_password
  validates :password, presence: true, length: { minimum: PASSWORD_MIN_LENGTH }, allow_nil: true

  validates :authorization_min, presence: true, numericality: { only_integer: true }

  def auth_revoked?(auth_value)
    authorization_min > auth_value
  end

  def revoke_auth
    update!(authorization_min: self.authorization_min += 1)
  end
end
