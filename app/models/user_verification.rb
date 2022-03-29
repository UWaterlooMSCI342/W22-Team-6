class UserVerification < ApplicationRecord
  require 'csv'

  belongs_to :team

  validates_presence_of :email
  validates :email, uniqueness: { scope: :team, message: "and Team combination has already been specified" }
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, if: -> { email.nil? || !email.empty? }

  # TODO: Implement testing.
  # https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
  def self.import(file)
    UserVerification.transaction do
      CSV.foreach(file.path, headers: true) do |row|
        team = Team.find_by(team_code: row["team_code"])
        UserVerification.create!(team: team, email: row["email"])
      end
    end
  end
end
