require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a student, I should be able to click on my team name, and be taken to my team's profile.
# 2. As a professor, I should be able to click on a given team name, and be taken to the respective team's profile.

class LinkTeamNameToTeamProfileTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', password: 'professor', password_confirmation: 'professor', is_admin: true)
    @user = User.new(email: 'test@test.com', name: 'Test Student', password: 'password', password_confirmation: 'password', is_admin: false)
    @team = Team.create(team_name: 'Team 1', team_code: 'TEAM01', user: @prof)
    @user.teams << @team
    @user.save!

    @feedback = save_feedback(5, 5, 5, "I submitted feedback!", @user, DateTime.civil_from_format(:local, 2022, 1, 20), @team)
  end

  def test_student_clicks_on_team_name_from_home
    visit root_url 
    login 'test@test.com', 'password'

    click_on @team.team_name
    assert_current_path team_path(@team)
    assert_text "Team Name: #{@team.team_name}"
  end

  def test_professor_clicks_on_team_from_home
    visit root_url 
    login 'msmucker@gmail.com', 'professor'

    within('#' + @team.id.to_s) do 
      click_on @team.team_name
    end

    assert_current_path team_path(@team)
    assert_text "Team Name: #{@team.team_name}"
  end

  def test_professor_clicks_on_team_from_teams_index
    visit root_url 
    login 'msmucker@gmail.com', 'professor'

    visit teams_url
    click_on @team.team_name
    assert_current_path team_path(@team)
    assert_text "Team Name: #{@team.team_name}"
  end

  def test_professor_clicks_on_team_from_users_index
    visit root_url 
    login 'msmucker@gmail.com', 'professor'

    visit users_url
    click_on @team.team_name
    assert_current_path team_path(@team)
    assert_text "Team Name: #{@team.team_name}"
  end

  def test_professor_clicks_on_team_from_user_profile
    visit root_url 
    login 'msmucker@gmail.com', 'professor'

    visit user_path(@user)
    click_on @team.team_name
    assert_current_path team_path(@team)
    assert_text "Team Name: #{@team.team_name}"
  end

  def test_professor_clicks_on_team_from_feedbacks_index
    visit root_url 
    login 'msmucker@gmail.com', 'professor'

    visit feedbacks_url
    click_on @team.team_name
    assert_current_path team_path(@team)
    assert_text "Team Name: #{@team.team_name}"
  end

  def test_professor_clicks_on_team_from_feedback_show
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit feedback_path(@feedback)
    click_on @team.team_name
    assert_current_path team_path(@team)
    assert_text "Team Name: #{@team.team_name}"
  end
end
