require "application_system_test_case"

# Acceptance Criteria:
# 1. When create is clicked, report info entered should be stored in database
# 2. When dropdown is selected, list of all students in system should be displayed
# 3. The student should not be able to report themselves 
# 4. The student should not be able to report instructors 

class ReportStudentUsingDropdownUnvalidatedsTest < ApplicationSystemTestCase
  setup do
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @team2 = Team.create(team_name: 'Test Team 2', team_code: 'TEAM02', user: @prof)
    @bob = User.create(email: 'bob@gmail.com',first_name: 'Bob', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    @steve = User.create(email: 'steve@gmail.com',first_name: 'Steve', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @steve.teams << @team2
  end
  
  # (1, 2, 3, 4) 
  def test_add_report 
    visit root_url 
    login 'bob@gmail.com', 'testpassword'
    
    click_on "Submit a Report"
    
    # check that no admins are included in option field, and prof is not included
    find_all("reporteeOption").each { |option| assert_equal('Steve', option.text) }
    
    # report steve (who is on another team)
    select "Steve", from: "Reportee"
    fill_in "Description", with: "Did not get along well."
    click_on "Submit report"
    
    assert_current_path root_url
    
    Report.all.each{ |report| 
      assert_equal(@bob.id, report.reporter_id)
      assert_equal(@steve.id, report.reportee_id)
      assert_equal('Did not get along well.', report.description)
    }
  end
end
