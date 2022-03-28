class UserVerification < ApplicationRecord
  require 'csv'

  belongs_to :team

  validates_presence_of :email
  validates :email, uniqueness: { scope: :team, message: "and Team combination has already been taken" }
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, if: -> { email.nil? || !email.empty? }

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      row = row.to_hash
      team = Team.find_by(team_code: row["team"])
      UserVerification.create!(team: team, email: row["email"])
    end
  end
end
