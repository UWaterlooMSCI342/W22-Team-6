require "application_system_test_case"

class SignInUppercasesTest < ApplicationSystemTestCase
  setup do
    Option.create(reports_toggled: true)
    @generated_code = Team.generate_team_code
    @prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, user: @prof)
    @bob = User.create(email: 'bob@gmail.com', name: 'Bob', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
  end
    
  def test_sign_in_regular
    visit root_url 
    # Login as student
    login 'bob@gmail.com', 'testpassword'

    assert_text "Welcome, Bob"
    
  end
    
  def test_sign_in_uppercase
    visit root_url 
    # Login as student
    login 'BOB@gmail.com', 'testpassword'

    assert_text "Welcome, Bob"
    
  end
end
