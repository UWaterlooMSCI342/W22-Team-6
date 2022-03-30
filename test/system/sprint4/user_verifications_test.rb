require "application_system_test_case"

# Acceptance Criteria:
# 1. As a professor, I should be able to upload a CSV file and see the user verifications uploaded.
# 2. As a new user, I should only be able to sign up for a team that I am verified to be on.

class UserVerificationsTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', password: 'professor', password_confirmation: 'professor', is_admin: true)

    @team1 = Team.create(team_name: "Team 1", team_code: "123456", user: @prof)
    @team2 = Team.create(team_name: "Team 2", team_code: "abcdef", user: @prof)
  end

  def test_upload_user_verifications_csv_file_fail_then_success
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    click_on "User Verifications"

    # As professor, submit CSV with invalid data.
    attach_file("file", "#{Rails.root}/test/fixtures/files/row_with_invalid_email.csv")
    click_on "Import CSV"
    assert_current_path user_verifications_url
    assert_text "Validation failed:"

    # As professor, submit CSV with valid data.
    attach_file("file", "#{Rails.root}/test/fixtures/files/all_valid_data.csv")
    click_on "Import CSV"
    assert_current_path user_verifications_url
    assert_text "User Verifications successfully imported!"
    assert_text "abcdef test3@test.com"
    assert_text "123456 test1@test.com"
    assert_text "123456 test2@test.com"
  end

  def test_sign_up_for_team_not_verified_then_verified
    # Student is verified to join "Team 2".
    student_email = "student@test.com"
    UserVerification.create(team: @team2, email: student_email)

    # As new student, try signing up for "Team 1" (not verified to join "Team 1").
    visit root_url
    click_on "Sign Up"
    fill_in "user[first_name]", with: "Student"
    fill_in "user[last_name]", with: "Test"
    fill_in "user[team_code]", with: @team1.team_code
    fill_in "user[email]", with: student_email
    fill_in "user[password]", with: "password"
    fill_in "user[password_confirmation]", with: "password"
    click_on "Create account"

    assert_current_path users_url
    assert_text "Teams code incorrect for provided email"

    # As new student, try signing up for "Team 2" (verified to join "Team 2").
    visit root_url
    click_on "Sign Up"
    fill_in "user[first_name]", with: "Student"
    fill_in "user[last_name]", with: "Test"
    fill_in "user[team_code]", with: @team2.team_code
    fill_in "user[email]", with: student_email
    fill_in "user[password]", with: "password"
    fill_in "user[password_confirmation]", with: "password"
    click_on "Create account"

    assert_current_path root_url
    assert_text "User was successfully created."
    assert_text "Welcome, Student"
  end
end
