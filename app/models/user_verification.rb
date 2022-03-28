class UserVerification < ApplicationRecord
  belongs_to :team

  validates_presence_of :email
  validates_uniqueness_of :email, case_sensitive: false
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, if: -> { email.nil? || !email.empty? }
end
