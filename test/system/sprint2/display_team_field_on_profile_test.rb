require "application_system_test_case"
# Acceptance Criteria:
# 1. As a student, I should be able to see my team name on my profile page
# 2. As a professor, I should not be able to see the 'team' keyword on my profile page

class DisplayTeamFieldOnProfileTest < ApplicationSystemTestCase
   setup do
    @user = User.new(email: 'test@gmail.com', password: '123456789', password_confirmation: '123456789',first_name: 'Elon', last_name: 'Musk', is_admin: false)
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @user.teams << @team
    @user.save
  end 
  
  def test_as_student_see_team
    visit root_url
    login 'test@gmail.com', '123456789'
    visit user_url(@user)
    assert_text "Team: Test Team"
    
  end
  
  def test_as_professor_dont_see_team
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    visit user_url(@prof)
    assert_no_text "Team:"
  end

end
