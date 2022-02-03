require "application_system_test_case"


class DeleteFeedbackTest < ApplicationSystemTestCase
  setup do 
    @prof = User.new(email: 'msmucker@gmail.com', password: 'professor', password_confirmation: 'professor', name: 'Mark', is_admin: true)
    @prof.save
    @user = User.new(email: 'adam@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'Adam', is_admin: false)
    @user.save

    @team = Team.new(team_code: 'Code', team_name: 'Team 1')
    @team.user = @prof
    @team.save
    @user.teams << @team

    #create new feedback from student with comment and priority of 2 (low)
    @feedback = Feedback.new(participation_rating: 3, effort_rating: 9, punctuality_rating: 4, comments: "This team is disorganized", priority: 2)
    @feedback.timestamp = @feedback.format_time(DateTime.now)
    @feedback.user = @user
    @feedback.team = @user.teams.first
    
    @feedback.save
  end 
  
  def test_delete_feedback
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    click_on "Feedback & Ratings"
    assert_text "This team is disorganized"
    click_on "Delete Feedback"
    assert_no_text "This team is disorganized"
    assert_text "Feedback was successfully destroyed."
  end 

  def test_edit_feedback
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    click_on "Feedback & Ratings"
    click_on "Edit"
    select 5, :from => "Participation rating"
    select 5, :from => "Effort rating"
    select 3, :from => "Punctuality rating"
    fill_in "Comments", with: "New Comment"
    click_on "Update Feedback"
    assert_text "New Comment"
  end
end
