require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a user, The "Back" button should return me to the correct page regardless of the button's location.

class ConsistentBackButtonsTest < ApplicationSystemTestCase
  include FeedbacksHelper
  
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
  
  def test_manage_team_back_to_home_page
    #Check to verify that the user can go back to home page from the "Manage Team Page", teams#index
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "Manage Teams"
    assert_current_path teams_url
    
    click_on "Back"
    assert_current_path root_url
  end 
  
  def test_specific_team_show_back_to_teams_index
    #Check to verify that the user can go back to teams#index from team#show
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "Manage Teams"
    assert_current_path teams_url
    
     within('#team' + @team1.id.to_s) do
      click_on @team1.team_name
    end
    assert_current_path team_path(@team1)
    
    click_on "Back"
    assert_current_path teams_url
  end 
  
  def test_remove_user_from_team_back_to_specific_team_show
    #Check to verify that the user can go back to team#show from team delete user from team 
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "Manage Teams"
    assert_current_path teams_url
    
     within('#team' + @team1.id.to_s) do
      click_on @team1.team_name
    end
    
    click_on 'Remove User From Team'
    
    click_on "Back"
    assert_current_path team_path(@team1)
  end 
  
  def test_team_edit_back_to_team_index
     #Check to verify that the user can go back to teams#index from editing a team
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "Manage Teams"
    assert_current_path teams_url
    
    within('#team' + @team1.id.to_s) do
      click_on 'Edit'
    end
    
    assert_current_path edit_team_url(@team1)
    
    click_on "Back"
    
    assert_current_path teams_url
  end 
  
  def test_team_delete_back_to_team_index
     #Check to verify that the user can go back to teams#index from deleting a team 
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "Manage Teams"
    assert_current_path teams_url
    
    within('#team' + @team1.id.to_s) do
      click_on 'Delete Team'
    end
    assert_current_path team_confirm_delete_path(@team1)
    
    click_on "Back"
    assert_current_path teams_url
  end
  
  def test_user_show_back_to_users_index
    #Check that user can go from a speficic user's page back to the index of users
     visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "Manage Users"
    assert_current_path users_url
    
    within('#user' + @user1.id.to_s) do
      click_on @user1.first_name
    end
    
    assert_current_path user_path(@user1)
    
    click_on "Back"
    assert_current_path users_url
    
  end
  
  def test_user_delete_back_to_users_index
    #Check that user can go from a speficic user's page back to the index of users
     visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "Manage Users"
    assert_current_path users_url
    
    within('#user' + @user1.id.to_s) do
      click_on 'Delete User'
    end
    
    assert_current_path  user_confirm_delete_path(@user1)
    
    click_on "Back"
    assert_current_path users_url
  end 
  
  def test_detailed_team_view_back_to_prof_landing_page
    #Check that the professor can go from detailed team view back to landing page
     visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
     within('#' + @team1.id.to_s) do 
      click_on @team1.team_name
    end
    
    assert_current_path team_path(@team1)
    click_on "Back"
    assert_current_path root_url
  end 
  
  def test_student_feedback_back_to_landing_page
    #Check that students can go back from feedback page to their landing page
     visit root_url
    login 'adam@gmail.com', '123456789'
    assert_current_path root_url
    
    click_on "Submit for: #{@team1.team_name}"
    assert_current_path new_feedback_path
    
    click_on "Back"
    assert_current_path root_url
  end 
  
  def test_student_team_detailed_view_back_to_landing_page
    #Students can go back to their landing page after clicking on their team summary view per period  
    feedback = save_feedback(5,5,5, "Week 9 data 1", @user1, DateTime.civil_from_format(:local, 2021, 3, 1), @team1)
    visit root_url
    login 'adam@gmail.com', '123456789'
    assert_current_path root_url
  
    click_on @team1.team_name
    assert_current_path team_path(@team1)
    
    click_on "Back"
    assert_current_path root_url
  end
  
  def test_help_page_back_to_landing_professor
    #Check that a professor can go back to landing page when they go to the help page 
     visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "Help"
    assert_current_path help_url
    
    click_on "Back"
    assert_current_path root_url
  end 
  
  def test_reset_password_back_to_landing_page
    #Check that users can go back to home landing page after going to the reset password page
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "Change Password"
    assert_current_path reset_password_url
    
    click_on "Back"
    assert_current_path root_url
    
    click_on "Logout"
    visit root_url
    login 'adam@gmail.com', '123456789'
    assert_current_path root_url
    
    click_on "Change Password"
    assert_current_path reset_password_url
    
    click_on "Back"
    assert_current_path root_url
  end

  def test_user_profile
    #Check that users can go to user profile via navbar and go back to home landing page
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "User Profile"
    assert_current_path user_profile_path(@prof)

    click_on "Back"
    assert_current_path root_url
    
    click_on "Logout"
    visit root_url
    login 'adam@gmail.com', '123456789'
    assert_current_path root_url

    click_on "User Profile"
    assert_current_path user_profile_path(@user1)
  end

  def test_team_profile
    #Check that students can go to their team profile via navbar and go back to home landing page
    visit root_url
    login 'adam@gmail.com', '123456789'
    assert_current_path root_url

    click_on "Team Profile"
    assert_current_path team_profile_path(@team1)

    click_on "Back"
    assert_current_path root_url
  end
end
