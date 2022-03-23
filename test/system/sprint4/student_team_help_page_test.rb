require "application_system_test_case"

# Acceptance Criteria:
# 1. As a student, I should be able to see up to date instructions in the team help page.

class StudentTeamHelpPageTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', password: 'professor', password_confirmation: 'professor', is_admin: true)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @user = User.create(email: 'test@test.com', password: 'password', password_confirmation: 'password', first_name: 'Test', last_name: 'User', teams: [@team], is_admin: false)
  end

  def test_student_view_no_submission_on_current_week
    visit root_url
    login 'test@test.com', 'password'

    # Navigate to student's team help page.
    visit team_view_help_url

    # All different types of ratings should be mentioned.
    assert_text 'Average Participation Rating (Out of 5)'
    assert_text 'Average Effort Rating (Out of 5)'
    assert_text 'Average Punctuality Rating (Out of 5)'

    # All different types of priority levels should be mentioned.
    assert_text 'High'
    assert_text 'Medium'
    assert_text 'Low'
  end
end
