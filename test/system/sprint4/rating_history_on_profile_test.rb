require "application_system_test_case"
# Acceptance Criteria:
# 1. As a student, I should be able to see my team name on my profile page
# 2. As a professor, I should not be able to see the 'team' keyword on my profile page

class RatingHistoryOnProfileTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    create_many_feedbacks

    # user with no feedbacks
    @user4 = User.new(email: "user4@user4.com", first_name: "User4", last_name: "User4", password: "password", password_confirmation: "password", is_admin: false)
    team3 = Team.create(team_name: "Team3", team_code: "TEAM03", user: @prof)
    @user4.teams << team3
    @user4.save
  end 
  
  def test_as_student_see_rating_history
    visit root_url
    login 'user1@user1.com', 'password'
    visit user_url(@user1)
    
    assert_text "Historical Feedback"

    # see all 3 feedbacks
    assert_text "5"
    assert_text "Low"
    assert_text "2022-01-20 00:00 EST"
    assert_text "First week went great!"

    assert_text "3"
    assert_text "Medium"
    assert_text "2022-01-27 00:00 EST"
    assert_text "Second week was okay!"

    assert_text "1"
    assert_text "High"
    assert_text "2022-02-03 00:00 EST"
    assert_text "Third week was terrible!"
  end
  
  def test_as_professor_see_rating_history
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    visit user_url(@user1)

    assert_text "Student's Individual Feedback"

    # see all 3 feedbacks
    assert_text "5"
    assert_text "Low"
    assert_text "2022-01-20 00:00 EST"
    assert_text "First week went great!"

    assert_text "3"
    assert_text "Medium"
    assert_text "2022-01-27 00:00 EST"
    assert_text "Second week was okay!"

    assert_text "1"
    assert_text "High"
    assert_text "2022-02-03 00:00 EST"
    assert_text "Third week was terrible!"
  end

  def test_as_student_no_ratings
    visit root_url
    login 'user4@user4.com', 'password'
    visit user_url(@user4)
    
    assert_text "Historical Feedback"
    assert_text "No feedbacks yet!"
  end

  def test_as_professor_no_ratings
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    visit user_url(@user4)

    assert_text "Student's Individual Feedback"
    assert_text "No feedbacks yet!"
  end

end
