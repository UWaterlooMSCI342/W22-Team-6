require "application_system_test_case"

# Acceptance Criteria:
# 1. As a professor, I should be able to paginate the teams page by a defaulted 10 rows.
# 2. As a professor, I should be able to paginate the teams page by a selected number of rows.
# 3. As a professor, I should be able to paginate the users page by a defaulted 10 rows.
# 4. As a professor, I should be able to paginate the users page by a selected number of rows.
# 5. As a professor, I should be able to paginate the feedbacks page by a defaulted 10 rows.
# 6. As a professor, I should be able to paginate the feedbacks page by a selected number of rows.
# 7. As a professor, I should be able to paginate the feedbacks page by a selected number of rows, then sort the rows.
# 8. As a professor, I should be able to paginate the feedbacks page by a selected number of rows, then filter the rows.

class PaginateTablesTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', password: 'professor', password_confirmation: 'professor', is_admin: true)
    num_items = 22

    # Create 12 teams, users, and feedbacks.
    i = 1
    while i <= num_items  do
      team = Team.create(team_name: "Test Team#{i}", team_code: "TEAM#{i}", user: @prof)
      user = User.create(email: "user#{i}@user.com", first_name: "User#{i}", last_name: "Student#{i}", password: 'password', password_confirmation: 'password', is_admin: false, teams: [team])
      feedback = save_feedback(5, 5, 5, "This is from User#{i}", user, DateTime.now, team)
      i +=1
    end
  end

  def feedbacks_row num
    "User#{num} Student#{num} Test Team#{num}"
  end

  def test_paginate_teams_by_default
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit teams_url
    assert_text "Team3"
    assert_no_text "Team12"

    click_on "2"
    assert_no_text "Team3"
    assert_text "Team12"
  end

  def test_paginate_teams_by_selected_rows
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit teams_url
    select "5", :from => "per_page"
    click_on "Save"

    assert_text "Team3"
    assert_no_text "Team7"

    click_on "2"
    assert_no_text "Team3"
    assert_text "Team7"
  end

  def test_paginate_users_by_default
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit users_url
    assert_text "User3"
    assert_no_text "User12"

    click_on "2"
    assert_no_text "User3"
    assert_text "User12"
  end

  def test_paginate_users_by_selected_rows
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit users_url
    select "5", :from => "per_page"
    click_on "Save"

    assert_text "User3"
    assert_no_text "User7"

    click_on "2"
    assert_no_text "User3"
    assert_text "User7"
  end

  def test_paginate_feedbacks_by_default
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit feedbacks_url
    assert_text feedbacks_row(1)
    assert_no_text feedbacks_row(20)

    click_on "2"
    assert_no_text feedbacks_row(1)
    assert_text feedbacks_row(20)
  end

  def test_paginate_feedbacks_by_selected_rows
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit feedbacks_url
    select "5", :from => "per_page"
    click_on "Save"

    assert_text feedbacks_row(1)
    assert_no_text feedbacks_row(16)

    click_on "2"
    assert_no_text feedbacks_row(1)
    assert_text feedbacks_row(16)
  end

  def test_paginate_feedbacks_by_selected_rows_then_sort_rows
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    # Paginate by 5 rows.
    visit feedbacks_url
    select "5", :from => "per_page"
    click_on "Save"

    # Sort rows by "Team".
    click_on "Team"

    assert_text feedbacks_row(1)
    assert_text feedbacks_row(13)

    click_on "2"
    assert_text feedbacks_row(14)
    assert_text feedbacks_row(18)
  end

  def test_paginate_feedbacks_by_selected_rows_then_filter_rows
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    # Paginate by 5 rows.
    visit feedbacks_url
    select "5", :from => "per_page"
    click_on "Save"

    # Filter rows by "Team".
    select "Test Team1", :from => "team_name"
    click_on "Filter"

    # Only rows that should be displayed are from "Test Team1".
    assert_text feedbacks_row(1)
    assert_no_text feedbacks_row(2)
    assert_no_text feedbacks_row(13)
    assert_no_text feedbacks_row(14)
    assert_no_text feedbacks_row(20)
  end
end
