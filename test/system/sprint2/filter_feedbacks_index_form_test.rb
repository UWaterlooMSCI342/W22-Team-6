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
    select "5", from: "Participation rating"
    select "5", from: "Effort rating"
    select "5", from: "Punctuality rating"
    select "Low", from: "Priority"
    fill_in "Start date", with: "2022/01/18"
    fill_in "End date", with: "2022/01/23"
    click_on "Filter"

    assert_text "User1 User1 Team1 5 5 5 Low First week went great! 2022-01-20 00:00 EST"
  end
end
