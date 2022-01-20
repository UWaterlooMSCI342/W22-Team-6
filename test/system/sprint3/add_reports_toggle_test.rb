require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a professor, I should be able to turn off peer-to-peer student reporting

class AddReportsTogglesTest < ApplicationSystemTestCase
  setup do
    @generated_code = Team.generate_team_code
    @prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, user: @prof)
    @bob = User.create(email: 'bob@gmail.com', name: 'Bob', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    @steve = User.create(email: 'steve@gmail.com', name: 'Steve', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @steve.teams << @team
  end
  
  def test_enable_reports
    Report.destroy_all
    Option.destroy_all
    Option.create(reports_toggled: false)
    
    visit root_url 
    
    # Login as professor
    login 'msmucker@gmail.com', 'professor'
    
    # Verify that reports_toggled is initially false
    assert_equal(Option.first.reports_toggled, false)
    
    click_on "Reports"
    
    click_on "Toggle Reports"
    
    # Verify that after clicking the button, reports_toggled is now true
    assert_equal(Option.first.reports_toggled, true)
    
    click_on "Logout"
    
    # Login as student
    login 'bob@gmail.com', 'testpassword'
    
    click_on "Submit a Report"
    
    # Create report 
    select "Steve", from: "Reportee"
    select "Urgent", from: "Priority"
    fill_in "Description", with: "Testing"
    
    click_on "Submit report"
    
    assert_current_path root_url
    
    # Ensure report is submitted correctly
    Report.all.each{ |report| 
      assert_equal(@bob.id, report.reporter_id)
      assert_equal(0, report.priority)
      assert_equal('Testing', report.description)
    }
    
    # Ensure reports can be viewed correctly
    click_on "View Reports"
    assert_text 'Testing'
    
  end
  
  def test_disable_reports
    Option.destroy_all
    Option.create(reports_toggled: true)
    
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    
    # Verify that reports_toggled is initially true
    assert_equal(Option.first.reports_toggled, true)
    
    click_on "Reports"
    
    click_on "Toggle Reports"
    
    # Verify that after clicking the button, reports_toggled is now false
    assert_equal(Option.first.reports_toggled, false)
    
    click_on "Reports"
    assert_text "Reports are currently disabled."
    
    click_on "Back"
    click_on "Logout"
    
    # Login as student
    login 'bob@gmail.com', 'testpassword'
    
    # Ensure students do not have the option to submit or view reports
    assert_no_text "Submit Report"
    assert_no_text "View Reports"
    
  end
  

  
end