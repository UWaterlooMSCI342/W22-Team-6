require "application_system_test_case"

class RedirectHelpPathStudentTest < ApplicationSystemTestCase
  setup do
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    @generated_code = Team.generate_team_code
    @prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', is_admin: true, password: 'password', password_confirmation: 'password')
    @team = Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, user: @prof)
    @bob = User.create(email: 'bob@gmail.com', name: 'Bob', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
  end
  
  def test_access_help_as_professor
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    
    visit root_url 
    # Login as professor
    login 'msmucker@gmail.com', 'password'

    visit '/help'
    
    assert_current_path help_path
  end

  def test_access_help_as_student
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    
    visit root_url 
    # Login as student
    login 'bob@gmail.com', 'testpassword'

    visit '/help'

    assert_current_path root_url
  end
end
