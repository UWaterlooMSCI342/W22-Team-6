require "test_helper"

class UserVerificationTest < ActiveSupport::TestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', password: 'professor', password_confirmation: 'professor', is_admin: true)
    @team1 = Team.create(team_name: 'Team 1', team_code: '123456', user: @prof)
    @team2 = Team.create(team_name: 'Team 1', team_code: 'abcdef', user: @prof)

    @file_path = "test/fixtures/files/"
  end

  def test_import_all_valid_data
    file = Rack::Test::UploadedFile.new("#{@file_path}all_valid_data.csv", "text/csv")
    UserVerification.import(file)
    expected_verifications = 3
    assert_equal expected_verifications, UserVerification.count
  end

  def import_raise_csv_error(path, message, type = "text/csv")
    file = Rack::Test::UploadedFile.new("#{@file_path}#{path}", type)
    exception = assert_raises(Exception) { UserVerification.import(file) }
    assert_equal message, exception.message
  end

  def test_import_invalid_headers
    path = "invalid_headers.csv"
    message = "Invalid headers. Must follow 'team_code,email' format"
    import_raise_csv_error(path, message)
  end

  def test_import_row_with_blank_email
    path = "row_with_blank_email.csv"
    message = "Validation failed: Email can't be blank, Email is invalid"
    import_raise_csv_error(path, message)
  end

  def test_import_row_with_duplicate_email_team_combination
    path = "row_with_duplicate_email_team_combination.csv"
    message = "Validation failed: Email and Team combination has already been specified"
    import_raise_csv_error(path, message)
  end

  def test_import_row_with_invalid_email
    path = "row_with_invalid_email.csv"
    message = "Validation failed: Email is invalid"
    import_raise_csv_error(path, message)
  end

  def test_import_row_with_invalid_team
    path = "row_with_invalid_team.csv"
    message = "Validation failed: Team must exist"
    import_raise_csv_error(path, message)
  end
end
