require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a student, I should be able to see help instructions regarding submission of feedbacks

class AddInstructionsForStudentTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', password: 'professor', password_confirmation: 'professor', is_admin: true)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @user = User.create(email: 'test@test.com', first_name: 'Test', last_name: 'User', password: 'password', password_confirmation: 'password', teams: [@team], is_admin: false)
  end

  def test_feedback_instructions
    visit root_url 
    login 'test@test.com', 'password'    
    click_on "Submit for"
    assert_text "Please select a rating on how well you believe your team performed this period. These fields are mandatory."
  end
end
