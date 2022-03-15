require "application_system_test_case"

# Acceptance Criteria
# 1. Team details will be successfully added to database
# 2. Each team will have a unique associated code that students can use to join
# 3. Student should only be allowed to join the team they were given the code for

class CreateGenerateTeamFunctionsTest < ApplicationSystemTestCase
  # Test team can be created (1)
  def test_create_team
    # create professor 
    User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')

    # log professor in
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    # create new team
    click_on "Manage Teams"
    find('#new-team-link').click
    fill_in "Team name", with: "Test Team"
    fill_in "Team code", with: "TEAM01"
    click_on "Create Team"
    assert_text "Team was successfully created."
    click_on "Home"
    assert_text "Test Team"
   
    
    # log professor out
    visit root_url
    click_on "Logout"
  end 
  
  # Test student can use team code (2)
  def test_register_student  
    prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: prof)
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[first_name]", with: "Elon"
    fill_in "user[last_name]", with: "Musk"
    fill_in "user[team_code]", with: "TEAM01"
    fill_in "user[email]", with: "bob@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword"
    click_on "Create account"
    
    assert_current_path root_url
    assert_text "Welcome, Elon"
    click_on "Logout"
    
    # check student enrollment (professor)
    assert_current_path login_url 
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "Manage Teams"
    assert_text 'Elon'
  end
  
  # Test invalid team code
  def test_register_student_invalid_team  
    prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: prof)
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[first_name]", with: "Elon"
    fill_in "user[last_name]", with: "Musk"
    fill_in "user[team_code]", with: "TEAM02"
    fill_in "user[email]", with: "bob@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword"
    click_on "Create account"
    
    assert_current_path users_url
    assert_equal 0, team.users.count
  end
end
