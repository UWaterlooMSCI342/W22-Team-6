require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a user, when I input the correct login credentials, I should be able to login.
# 2. As a user, when I input an email of all uppercase letters, I should still be able to login.

class SignInUppercasesTest < ApplicationSystemTestCase
  setup do
    Option.create(reports_toggled: true)
    @generated_code = Team.generate_team_code
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, user: @prof)
    @bob = User.create(email: 'bob@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
  end
    
  def test_sign_in_regular
    visit root_url 
    # Login as student
    login 'bob@gmail.com', 'testpassword'

    assert_text "Welcome, Elon"
    
  end
    
  def test_sign_in_uppercase
    visit root_url 
    # Login as student
    login 'BOB@gmail.com', 'testpassword'

    assert_text "Welcome, Elon"
    
  end
end
