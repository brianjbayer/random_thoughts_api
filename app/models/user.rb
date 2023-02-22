# frozen_string_literal: true

# Represents a user of this application
class User < ApplicationRecord
  PASSWORD_MIN_LENGTH = 8

  validates :email, presence: true, uniqueness: true,
                    # NOTE: citext (db) does not support max length constraint
                    length: {
                      # Max email address length is actually 254
                      # see https://www.rfc-editor.org/errata_search.php?rfc=3696&eid=1690
                      maximum: 254
                    },
                    format: {
                      with: URI::MailTo::EMAIL_REGEXP,
                      message: 'must match URI::MailTo::EMAIL_REGEXP'
                    }

  validates :display_name, presence: true

  has_secure_password
  # TODO: When update is implemented...
  # https://stackoverflow.com/questions/6486305/has-secure-password-how-to-require-minimum-length
  validates :password, length: { minimum: PASSWORD_MIN_LENGTH }
end
