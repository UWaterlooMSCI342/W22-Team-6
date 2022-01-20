require "application_system_test_case"

# Acceptance Criteria
# 1. As a professor or TA, I can register to create an admin account using the admin code
# 2. As a student, I cannot register to create an admin account without the admin code

class ProfessorRegistrationPortalsTest < ApplicationSystemTestCase
  
  #(1)
  def test_signup_prof 
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADmin')
    Team.create(team_name: 'Test Team', team_code: 'TEAM01')
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[name]", with: "Professor"
    fill_in "user[team_code]", with: "ADmin"
    fill_in "user[email]", with: "prof@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword"
    click_on "Create account"
    
    assert_current_path root_url
    assert_text "Welcome, Professor"
    
    assert_text 'Manage Teams'
    assert_text 'Manage Users'
    
    click_on 'Manage Users'
    assert_text 'Professor'
  end
  
  #(2)
  def test_cannot_signup_prof 
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    Team.create(team_name: 'Test Team', team_code: 'TEAM01')
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[name]", with: "Professor"
    fill_in "user[team_code]", with: "notadmin"
    fill_in "user[email]", with: "prof@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword"
    click_on "Create account"
    
    assert_text 'Teams code does not exist'
    assert_current_path users_path
  end
end
