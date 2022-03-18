require "application_system_test_case"

# Acceptance Criteria:
# 1. As a professor, I should be able to input, clear, and submit filtering criteria for feedbacks.

class FilterFeedbacksIndexFormTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', password: 'professor', password_confirmation: 'professor', is_admin: true)
    feedbacks = create_many_feedbacks
  end
  
  def test_filter_feedbacks_submitting_fields
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    click_on "Feedback & Ratings"

    fill_in "First name", with: "User1"
    fill_in "Last name", with: "User1"
    select "Team1", from: "Team"
    select "5", from: "participation_rating_start"
    select "5", from: "participation_rating_end"
    select "5", from: "effort_rating_start"
    select "5", from: "effort_rating_end"
    select "5", from: "punctuality_rating_start"
    select "5", from: "punctuality_rating_end"
    select "Low", from: "Priority"
    fill_in "Start date", with: "2022-01-18"
    fill_in "End date", with: "2022-01-23"
    click_on "Filter"

    assert_text "Applied filters:"
    assert_text "First Name: User1"
    assert_text "Last Name: User1"
    assert_text "Team: Team1"
    assert_text "Participation Rating: 5"
    assert_text "Effort Rating: 5"
    assert_text "Punctuality Rating: 5"
    assert_text "Priority: Low"
    assert_text "Timestamp: 2022-01-18 to 2022-01-23"
    assert_text "User1 User1 Team1 5 5 5 Low First week went great! 2022-01-20 00:00 EST"
  end

  def test_filter_feedbacks_reset
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    click_on "Feedback & Ratings"

    fill_in "First name", with: "User1"
    click_on "Filter"
    
    click_on "Reset"

    assert_current_path feedbacks_url
  end
end
