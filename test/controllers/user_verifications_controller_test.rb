require "test_helper"

class UserVerificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Option.create
    @prof = User.create(email: "msmucker@gmail.com", first_name: "Mark", last_name: "Smucker", password: "professor", password_confirmation: "professor", is_admin: true)

    @team1 = Team.create(team_name: "Team 1", team_code: "123456", user: @prof)
    @team2 = Team.create(team_name: "Team 2", team_code: "abcdef", user: @prof)

    @file_path = "test/fixtures/files/"

    post('/login', params: { email: "msmucker@gmail.com", password: "professor"})
  end

  def test_access_index
    get user_verifications_url
    assert_response :success
  end

  def test_import_success
    file = Rack::Test::UploadedFile.new("#{@file_path}all_valid_data.csv", "text/csv")
    post(user_verifications_import_url, params: { file: file })
    assert_redirected_to user_verifications_url
    assert "User Verifications successfully imported!"
  end

  def test_import_failure
    file = Rack::Test::UploadedFile.new("#{@file_path}row_with_invalid_email.csv", "text/csv")
    post(user_verifications_import_url, params: { file: file })
    assert_redirected_to user_verifications_url
    assert "Validation failed:"
  end
end
