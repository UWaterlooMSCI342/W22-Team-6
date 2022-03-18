require "application_system_test_case"

# Acceptance Criteria:
# 1. As a professor, I should be able to paginate the teams page.
# 2. As a professor, I should be able to paginate the users page.
# 3. As a professor, I should be able to paginate the feedbacks page.

class PaginateTablesTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', password: 'professor', password_confirmation: 'professor', is_admin: true)
    num_items = 12

    # Create 12 teams, users, and feedbacks.
    i = 1
    while i <= num_items  do
      team = Team.create(team_name: "Test Team#{i}", team_code: "TEAM#{i}", user: @prof)
      user = User.create(email: "user#{i}@user.com", first_name: "User#{i}", last_name: "Student#{i}", password: 'password', password_confirmation: 'password', is_admin: false, teams: [team])
      feedback = save_feedback(5, 5, 5, "This is from User#{i}", user, DateTime.now, team)
      i +=1
    end
  end

  def test_paginate_teams_index
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit teams_url
    assert_text "Team2"
    assert_no_text "Team12"

    click_on "2"
    assert_no_text "Team2"
    assert_text "Team12"
  end

  def test_paginate_users_index
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit users_url
    assert_text "User2"
    assert_no_text "User12"

    click_on "2"
    assert_no_text "User2"
    assert_text "User12"
  end

  def test_paginate_feedbacks_index
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit feedbacks_url
    click_on "2"
    assert :success
  end
end
