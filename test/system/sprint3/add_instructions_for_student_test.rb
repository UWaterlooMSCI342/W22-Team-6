require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a student, I should be able to see help instructions regarding submission of feedbacks
# 2. As a student, I should be able to see help instructions regarding submission of reports

class AddReportsTogglesTest < ApplicationSystemTestCase
  setup do
    Option.create(reports_toggled: true)
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @steve = User.create(email: 'steve@gmail.com',first_name: 'Steve', last_name: '', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
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
    
    click_on "Submit a Report"
    assert_text "Please select the user you wish to report and the priority of your report from the dropdowns below. Please enter a description with a maximum length of 2048 characters. These fields are mandatory."
  end
  
end