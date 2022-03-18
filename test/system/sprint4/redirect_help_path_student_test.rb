require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a logged in user, I should be able to access the "Help" page.

class RedirectHelpPathStudentTest < ApplicationSystemTestCase
  setup do
    Option.destroy_all
    Option.create(admin_code: 'ADMIN')
    @generated_code = Team.generate_team_code
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'password', password_confirmation: 'password')
    @team = Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, user: @prof)
    @bob = User.create(email: 'bob@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
  end
  
  def test_access_help_as_professor
    visit root_url 
    # Login as professor
    login 'msmucker@gmail.com', 'password'

    visit '/help'
    
    assert_current_path help_path
  end

  def test_access_help_as_student
    visit root_url 
    # Login as student
    login 'bob@gmail.com', 'testpassword'

    visit '/help'

    assert_current_path root_url
  end
end
