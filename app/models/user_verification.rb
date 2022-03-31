class UserVerification < ApplicationRecord
  require 'csv'

  belongs_to :team

  validates_presence_of :email
  validates_length_of :email, maximum: 255
  validates :email, uniqueness: { scope: :team, message: "and Team combination has already been specified" }
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, if: -> { email.nil? || !email.empty? }

  # Assumes that the CSV file imported is correctly formatted, or else just generally catches errors.
  # https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
  def self.import(file)
    # TODO: This error check does not fully work since there are multiple CSV types.
    # If file not of type CSV, throw error.
    # expected_type = "text/csv"
    # if file.content_type != expected_type
    #   raise "Invalid file type. Must be of type CSV"
    # end

    read_file = CSV.read(file, headers: true)

    correct_headers = ["team_code", "email"]
    if correct_headers != read_file.headers # If file has incorrect headers, throw error.
      raise "Invalid headers. Must follow '#{correct_headers[0]},#{correct_headers[1]}' format"
    elsif read_file.count < 2 # If file has no data, throw error.
      raise "No data provided"
    end

    # If any UserVerification is invalid, rollback all records.
    UserVerification.transaction do
      CSV.foreach(file.path, headers: true) do |row|
        team = Team.find_by(team_code: row[correct_headers[0]])
        UserVerification.create!(team: team, email: row[correct_headers[1]])
      end
    end
  end
end
