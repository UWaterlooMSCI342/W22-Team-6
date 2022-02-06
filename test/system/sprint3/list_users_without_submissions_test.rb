require "application_system_test_case"

# 1. As a professor, I should be able to see student's that have not 
#    submitted feedbacks for team summary view
# 2. As a professor, I should be able to see student's that have not 
#    submitted feedbacks for team detailed view

class ListUsersWithoutSubmissionsTest < ApplicationSystemTestCase
  setup do
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2, user3]
    team.user = @prof 
    team.save!     
    
    feedback = save_feedback(5,5,5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    feedback2 = save_feedback(3,3,3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team)
  end
  
  # (1)
  def test_not_submitted_feedback_summary_view 
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url 
    
    assert_text "Missing Feedback"
    assert_text "Charles3 "
  end 
  
  # (2)
  def test_not_submitted_feedback_detailed_view 
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url 
    click_on "Details"
    
    assert_text "Missing Feedback: Charles3"
  end 
end
