require "application_system_test_case"

# Acceptance Criteria
# 1. As a user, I should be able to view a help page regarding the application
# 2. As a user, I should be able to view a help page regarding feedback results for detailed
#    team view

class HelpPageTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
  end
  
  # (1)
  def test_home_help
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    click_on 'Help'
    assert_text 'Help page'
  end

  # (2)
  def test_teams_view_help
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!
    user = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', is_admin: false, teams: [team])
    user.save!
    feedback = Feedback.new(participation_rating: 3, effort_rating: 9, punctuality_rating: 4, comments: "This team is disorganized", priority: 2)
    feedback.timestamp = feedback.format_time(DateTime.now)
    feedback.user = user
    feedback.team = user.teams.first
    feedback.save!

    visit root_url
    login 'msmucker@gmail.com', 'professor' 
    within('#' + team.id.to_s) do
      click_on team.team_name
    end
    click_on 'Help'
    assert_text "Team's Individual Feedback"
  end

  def test_filter_instructions
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit help_url

    # assert section exists
    assert_text("Feedback & Ratings Filter")

    # assert options for filtering exist
    assert_text("First Name")
    assert_text("Last Name")
    assert_text("Team Name")
    assert_text("Participation Rating")
    assert_text("Effort Rating")
    assert_text("Punctuality Rating")
    assert_text("Priority")
    assert_text("Timestamp")

    # assert specific functionality of options
    ratings = ["participation", "effort", "punctuality"]
    ratings.each do |r|
        assert_text("selected range of #{r} ratings")
    end
  end
end