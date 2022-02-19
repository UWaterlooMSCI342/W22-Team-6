require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a student, I can view reports that label me as a reportee so I can address those concerns
# 2. As a student, I cannot view who reported me
# 3. As a student, I cannot view reports that do not concern me so we maintain privacy
# 4. As a student, I can view reports I have submitted so I can keep track of my reports

class AddStudentViewsForReportsTest < ApplicationSystemTestCase
  setup do
    # Create prof, team, and users
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @bob = User.create(email: 'bob@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    @steve = User.create(email: 'steve@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @steve.teams << @team
    @anna = User.create(email: 'anna@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @anna.teams << @team
    Report.create(reporter_id: @bob.id, reportee_id: @steve.id, description: 'Made fun of my shirt.', priority: 0)
    Report.create(reporter_id: @anna.id, reportee_id: @bob.id, description: 'Laughed at my haircut.', priority: 0)
  end
  
  def test_view_reports_as_reportee
    visit root_url 
    login 'steve@gmail.com', 'testpassword'
    
    click_on "Reports"
    assert_current_path reports_url
    
    # Ensure that Bob's submitted report information is visible
    assert_text 'Steve'
    assert_text 'Made fun of my shirt.'
  end
  
  def test_cannot_view_reporter_as_reportee
    visit root_url 
    login 'steve@gmail.com', 'testpassword'
    
    click_on "Reports"
    assert_current_path reports_url
    
    # Ensure that Bob is not visible to Steve
    assert_no_text 'Bob'
  end
  
  def test_cannot_view_irrelevant_reports
    visit root_url 
    login 'steve@gmail.com', 'testpassword'
    
    click_on "Reports"
    assert_current_path reports_url
    
    # Ensure that Anna's report is not visible
    assert_no_text 'Laughed at my haircut.'
  end
  
  def test_can_view_submitted_reports
    visit root_url 
    login 'anna@gmail.com', 'testpassword'
    
    click_on "Reports"
    assert_current_path reports_url
    
    # Ensure that Anna's submitted report is visible
    assert_text 'Bob'
    assert_text 'Anna'
    assert_text 'Laughed at my haircut.'
  end
  

  
end