require "application_system_test_case"

# Acceptance Criteria
# 1. As a professor, I should be able to delete/disband a team
# 2. As a student, I should not be able to delete any team

class AddDeleteTeamsTest < ApplicationSystemTestCase
  setup do 
    @prof = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: true)
    @prof.save
    @user1 = User.new(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: false)
    @user1.save

    @team1 = Team.new(team_code: 'Code', team_name: 'Team 1')
    @team1.user = @prof
    @team1.save
    @user1.teams << @team1

    @team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    @team2.user = @prof
    @team2.save
    
    @user2 = User.new(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: false)
    @user2.teams = [@team2]
    @user2.save
    
    @feedback = save_feedback(5,4,2, "This team is disorganized", @user, DateTime.civil_from_format(:local, 2021, 3, 1), @team1, 2)
    @feedback2 = save_feedback(5,3,4, "This team is disorganized", @user, DateTime.civil_from_format(:local, 2021, 3, 3), @team1, 2)
    @feedback3 = save_feedback(5,2,3, "This team is disorganized", @user2, DateTime.civil_from_format(:local, 2021, 3, 3), @team2, 2)
  end 
  
  # (1)
  def test_delete_team_professor 
    visit root_url
    login 'charles@gmail.com', 'banana'
    assert_current_path root_url
    
    click_on 'Manage Teams'
    assert_current_path teams_url 
    
    within('#team' + @team1.id.to_s) do
      assert_text 'Team 1'
      click_on 'Delete Team'
    end
    
    assert_current_path team_confirm_delete_path(@team1)
    assert_text "Confirm Delete #{@team1.team_name}"
    click_on "Delete Team"
    
    assert_current_path teams_url 
    assert_text "Team was successfully destroyed"
    assert_no_text "Team 1"
    assert_text "Team 2"
  end
  
  #(2)
  def test_delete_team_student 
    visit root_url
    login 'charles2@gmail.com', 'banana'
    assert_current_path root_url
    
    assert_no_text 'Manage Teams'
    
    # Testing of security of path (e.g. cannot directly send DELETE request) 
    # included in controller
  end
end
