require "application_system_test_case"

# Acceptance Criteria:
# 1. As a professor, I can view the admin code
# 2. As a professor, I can regenerate the admin code
# 3. As a student, I cannot view the admin code
# 4. As a student, I cannot regenerate the admin code

class AddAdminCodesTest < ApplicationSystemTestCase
  setup do 
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @bob = User.create(email: 'bob@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    
    Option.destroy_all
    Option.create(admin_code: 'admin_CODE')
  end 
  
  # (1)
  def test_view_admin_code 
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    
    assert_text 'admin_CODE'
  end
  
  # (3)
  def test_cannot_view_admin_code 
    visit root_url 
    login 'bob@gmail.com', 'testpassword'
    
    assert_no_text 'admin_CODE'
  end
  
  # (2)
  def test_regenerate_admin_code 
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    
    click_on 'Regenerate Code'
    assert_current_path root_url
    assert_text 'Admin code has successfully been regenerated'
    assert_not_equal 'admin_CODE', Option.first.admin_code 
  end
  
  # (4)
  def test_cannot_regenerate_admin_code
    visit root_url 
    login 'bob@gmail.com', 'testpassword'
    
    assert_no_text 'Regenerate Code'
    
    visit regenerate_admin_code_path
    assert_text 'You do not have permission to update admin code'
    assert_equal 'admin_CODE', Option.first.admin_code 
  end
  
  # 04/09/2021: bugfix - test that team cannot be created with admin code
  def test_cannot_use_code_for_team 
    visit root_url 
    login 'msmucker@gmail.com', 'professor'

    click_on "Manage Teams"
    find('#new-team-link').click
    fill_in "Team name", with: "Test Team"
    fill_in "Team code", with: "admin_CODE"
    click_on "Create Team"
    assert_text "Team code not unique"
    assert_current_path teams_path
  end
end
