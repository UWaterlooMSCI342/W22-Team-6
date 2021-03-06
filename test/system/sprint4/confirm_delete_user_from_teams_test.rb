require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a professor, I should be given a confirmation message when deleting a user from a team.

class ConfirmDeleteUserFromTeamsTest < ApplicationSystemTestCase
  setup do 
    @prof = User.new(email: 'msmucker@gmail.com', password: 'professor', password_confirmation: 'professor', first_name: 'Mark', last_name: 'Smucker', is_admin: true)
    @prof.save
    @user1 = User.new(email: 'adam@gmail.com', password: '123456789', password_confirmation: '123456789',first_name: 'Elon', last_name: 'Musk', is_admin: false)
    @user1.save

    @team1 = Team.new(team_code: 'Code', team_name: 'Team 1')
    @team1.user = @prof
    @team1.save
    @user1.teams << @team1
  end
    
  def test_get_confirm_message_when_deleting_user_from_team
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url

    click_on 'Manage Teams'
    assert_current_path teams_url 
    
    within('#team' + @team1.id.to_s) do
      assert_text 'Team 1'
      assert_text 'Elon Musk'
      click_on @team1.team_name
    end

    assert_text 'Elon Musk'
    click_on 'Remove User From Team'
   
    assert_equal 1, Team.count
    #professor and student
    assert_equal 2, User.count
      
    assert_equal([@user1], @team1.users)
   
    assert_text 'Confirm Remove Elon Musk from Team 1'
    click_on 'Remove User'
      
    assert_current_path root_url
    assert_text 'User removed successfully.'
    assert_no_text 'Elon Musk'
    @team = Team.find_by team_code: 'Code'
    assert_equal([], @team.users)
  end
end
