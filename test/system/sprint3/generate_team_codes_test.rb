require "application_system_test_case"

# Acceptance Criteria
# 1. As a professor, when I create a team, a generated team code is provided to allow students to add themselves to the team
# 2. As a student, I can use the generated team code to register an account associated with the team

class GenerateTeamCodesTest < ApplicationSystemTestCase
  setup do
    Option.create

    #Create a generated team code
    @generated_code = Team.generate_team_code
  end
  
  #(1)
  def test_prof_team_creation_with_generated_code
    #(1) Passes acceptance criteria 1: As a professor, when I create a team, a generated team code is provided to allow students to add themselves to the team    
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
    fill_in "Team code", with: @generated_code.to_s
    click_on "Create Team"
    assert_text "Team was successfully created."
    click_on "Home"
    assert_text "Test Team"
    assert_text @generated_code.to_s
    
    # log professor out
    visit root_url
    click_on "Logout"
  end 
  
  #(2)
  def test_student_account_creation_with_generated_team_code
    #(2) Passes acceptance criteria 2: As a student, I can use the generated team code to register an account associated with the team
    prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, user: prof)
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[first_name]", with: "Elon"
    fill_in "user[last_name]", with: "Musk"
    fill_in "user[team_code]", with: @generated_code.to_s
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
    assert_text @generated_code.to_s
    assert_text 'Test Team'
    
    
  end
  
  
end
