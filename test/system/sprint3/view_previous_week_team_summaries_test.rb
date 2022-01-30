require "application_system_test_case"
# Acceptance Criteria:
# 1. As a professor, I should be able to view the pervious week's summary for all teams
# 2. As a student, I should be able to view the pervious week's summary for my current team

class ViewPreviousWeekTeamSummariesTest < ApplicationSystemTestCase
  include FeedbacksHelper
  
  setup do
    @user = User.new(email: 'test@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'Adam', is_admin: false)
    @user2 = User.new(email: 'test2@gmail.com', password: '1234567891', password_confirmation: '1234567891', name: 'Adam2', is_admin: false)
    @prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @team2 = Team.create(team_name: 'Test Team 2', team_code: 'TEAM02', user: @prof)
    @user.teams << @team
    @user.save!
    @user2.teams << @team2
    @user2.save!
    
    @week_range = week_range(2021, 7)
    #sets the app's date to week of Feb 15 - 21, 2021 for testing
    travel_to Time.new(2021, 02, 15, 06, 04, 44)
  end 
  
  def save_feedback(participation_rating, effort_rating, punctuality_rating, comments, user, timestamp, team, priority)
    feedback = Feedback.new(participation_rating: participation_rating, effort_rating: effort_rating, punctuality_rating: punctuality_rating, comments: comments, priority: priority)
    feedback.user = user
    feedback.timestamp = feedback.format_time(timestamp)
    feedback.team = team
    feedback.save
    feedback
  end
  
  #(1)
  def test_professor_view_previous_week_data_team_summary
    #Passes criteria 1: As a professor, I should be able to view the pervious week's summary for all teams
    
    #feedback for week 6 (1 week previous from current week of 7)
    feedback1 = save_feedback(3, "User1 Week 6 Data", @user, DateTime.civil_from_format(:local, 2021, 2, 8), @team, 0)
    feedback2 = save_feedback(4, "User1 Week 6 Data", @user2, DateTime.civil_from_format(:local, 2021, 2, 9), @team2, 1)
    
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url 
    
    assert_text 'Previous Week: ' + (@week_range[:start_date] - 7.days).strftime('%b %-e, %Y').to_s + " to " + (@week_range[:end_date] - 7.days).strftime('%b %-e, %Y').to_s
    assert_text 'High'
    assert_text 'Medium'
    assert_text 3.0.to_s
    assert_text 4.0.to_s
  end 
  
  #(2)
  def test_student_view_previous_week_team_summary
    #Passes criteria 2: As a student, I should be able to view the pervious week's summary for my current team
    
    #feedback for week 6 (1 week previous from current week of 7)
    feedback1 = save_feedback(3, "User1 Week 6 Data", @user, DateTime.civil_from_format(:local, 2021, 2, 8), @team, 0)
    
    visit root_url 
    login 'test@gmail.com', '123456789'
    assert_current_path root_url 
    
    assert_text 'Previous Week: ' + (@week_range[:start_date] - 7.days).strftime("%b %-e, %Y").to_s + " to " + (@week_range[:end_date] - 7.days).strftime('%-b %-e, %Y').to_s
    assert_text 'High'
    assert_text 3.0.to_s
  end
  
end
