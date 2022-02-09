require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a student, I should be able to see help instructions regarding submission of feedbacks
# 2. As a student, I should be able to see help instructions regarding submission of reports

class AddReportsTogglesTest < ApplicationSystemTestCase
  setup do
    Option.create(reports_toggled: true)
    @prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @steve = User.create(email: 'steve@gmail.com', name: 'Steve', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @steve.teams << @team
  end
  
  def test_feedback_instructions
    visit root_url 
    login 'steve@gmail.com', 'testpassword'    
    
    click_on "Submit for"
    assert_text "Please select a rating on how well you believe your team performed this period. These fields are mandatory."
  end

  def test_report_instructions
    visit root_url 
    login 'steve@gmail.com', 'testpassword'    
    
    click_on "Submit for"
    assert_text "In the participation rating field, please rank how actively your team members participated in any discussions and meetings about the project that were held this week."
    assert_text "In the effort rating field, please rank how well your team members attempted to contribute to the week's deliverables, and whether they sought out any resources they needed."
    assert_text "In the punctuality rating field, please rank how well your team members were at being on time to meetings, and communicating any important information ahead of time."
    assert_text "You may enter optional comments in the text area below with a maximum of 2048 characters."
  end
  
end