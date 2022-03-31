require "application_system_test_case"
# Acceptance Criteria:
# 1. As a student, I am able to submit a feedback with a priority
# 2. As a professor, I am able to view an individual team's priority for a time period
# 3. As a professor, I am able to view overall priority for all team's summary view

class AddPriorityToFeedbacksTest < ApplicationSystemTestCase
  include FeedbacksHelper
  
  setup do 
    @user = User.new(email: 'test@gmail.com', password: '123456789', password_confirmation: '123456789',first_name: 'Elon', last_name: 'Musk', is_admin: false)
    @user2 = User.new(email: 'test2@gmail.com', password: '1234567891', password_confirmation: '1234567891',first_name: 'Elon', last_name: 'Musk', is_admin: false)
    @user10 = User.new(email: 'test10@gmail.com', password: '1234567891', password_confirmation: '1234567891',first_name: 'Elon', last_name: 'Musk', is_admin: false)
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @user.teams << @team
    @user.save!
    @user2.teams << @team
    @user2.save!
    @user10.teams << @team
    @user10.save!
    
    @week_range = week_range(2021, 7)
    #sets the app's date to week of Feb 15 - 21, 2021 for testing
    travel_to Time.new(2021, 02, 15, 06, 04, 44)
  end 
  
  def test_create_feedback_with_no_priority
    #Passes acceptance criteria 1: Student submits a feedback with no user selected priority, instead the default value for priority is 2, meaning 'low' priority
    visit root_url
    login 'test@gmail.com', '123456789'
    assert_current_path root_url
    
    click_on "Submit for"
    
    select 5, :from => "Participation rating"
    select 5, :from => "Effort rating"
    select 5, :from => "Punctuality rating"
    fill_in "Comments", with: "I did not select a priority, default of low set"
    click_on "Create Feedback"
    assert_current_path feedback_url(Feedback.last)
    assert_text "Feedback was successfully created."
  end 
  
  def test_create_feedback_with_high_priority
    #Passes acceptance criteria 1: Student submits a feedback with a selected priority
    visit root_url
    login 'test@gmail.com', '123456789'
    assert_current_path root_url
    
    click_on "Submit for"
    
    select 1, :from => "Participation rating"
    select 1, :from => "Effort rating"
    select 1, :from => "Punctuality rating"
    fill_in "Comments", with: "I selected a priority, it's URGENT"
    click_on "Create Feedback"
    assert_current_path feedback_url(Feedback.last)
    assert_text "Feedback was successfully created."
  end

  def test_create_feedback_with_medium_priority
    #Passes acceptance criteria 1: Student submits a feedback with a selected priority
    visit root_url
    login 'test@gmail.com', '123456789'
    assert_current_path root_url
    
    click_on "Submit for"
    
    select 3, :from => "Participation rating"
    select 3, :from => "Effort rating"
    select 3, :from => "Punctuality rating"
    fill_in "Comments", with: "I selected a priority, it's URGENT"
    click_on "Create Feedback"
    assert_current_path feedback_url(Feedback.last)
    assert_text "Feedback was successfully created."
  end

  def test_create_feedback_with_low_priority
    #Passes acceptance criteria 1: Student submits a feedback with a selected priority
    visit root_url
    login 'test@gmail.com', '123456789'
    assert_current_path root_url
    
    click_on "Submit for"
    
    select 5, :from => "Participation rating"
    select 5, :from => "Effort rating"
    select 5, :from => "Punctuality rating"
    fill_in "Comments", with: "I selected a priority, it's URGENT"
    click_on "Create Feedback"
    assert_current_path feedback_url(Feedback.last)
    assert_text "Feedback was successfully created."
  end
  
  def test_professor_individual_team_priority_view_timeperiod
    #Passes acceptance criteria 2: As a professor, I am able to view an individual team's priority for a time period

    feedback = save_feedback(5,5,5, "Week 9 data 1", @user, DateTime.civil_from_format(:local, 2021, 3, 1), @team)
    feedback2 = save_feedback(4,4,4, "Week 9 data 2", @user2, DateTime.civil_from_format(:local, 2021, 3, 3), @team)
    feedback3 = save_feedback(3,3,3, "Week 7 data 1", @user, DateTime.civil_from_format(:local, 2021, 2, 15), @team)
    feedback4 = save_feedback(2,2,2, "Week 7 data 2", @user2, DateTime.civil_from_format(:local, 2021, 2, 16), @team)
    
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url 
    within('#' + @team.id.to_s) do
      click_on @team.team_name
    end
    assert_current_path team_path(@team)
    
    # within('#2021-7') do
    #   assert_text 'Feb 15, 2021 to Feb 21, 2021'
    #   assert_text 'Medium'
    #   assert_text 'Medium'
    #   assert_text 'Week 7 data 1'
    #   assert_text 'Week 7 data 2'
    #   assert_text '2021-02-15'
    #   assert_text '2021-02-16'
    # end
    within('#2021-9') do
      assert_text 'Mar 1, 2021 to Mar 7, 2021'
      assert_text 'Low'
      assert_text 'Low'
      assert_text 'Week 9 data 1'
      assert_text 'Week 9 data 2'
      assert_text '2021-03-01'
      assert_text '2021-03-03'
    end
  end 
  
  def test_professor_summary_team_priority_view_timeperiod_urgent_status
    #Passes acceptance criteria 3: As a professor, I am able to view overall priority for all team's summary view
    #Case 1, professor should see a team's overall priority as "High" under team Urgency/Intervention column if at least one student gave a priority of "urgent" for feedback
    
    feedback1 = save_feedback(4,4,4, "Data1", @user, DateTime.civil_from_format(:local, 2021, 2, 15), @team)
    feedback2 = save_feedback(3,3,3, "Data2", @user2, DateTime.civil_from_format(:local, 2021, 2, 16), @team)
    feedback3 = save_feedback(1,1,1, "Data2", @user10, DateTime.civil_from_format(:local, 2021, 2, 16), @team)
    
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url 
    
    assert_text 'Current Week: ' + @week_range[:start_date].strftime('%b %-e, %Y').to_s + " to " + @week_range[:end_date].strftime('%b %-e, %Y').to_s
    assert_text 'High'
  end 
  
  def test_professor_summary_team_priority_view_timeperiod_medium_status
    #Passes acceptance criteria 3: As a professor, I am able to view overall priority for all team's summary view
    #Case 2, professor should see a team's overall priority as "Medium" under team Urgency/Intervention column if the average ratings are at the middle of the scale.
    
    feedback4 = save_feedback(3,3,3, "Data1", @user, DateTime.civil_from_format(:local, 2021, 2, 15), @team)
    feedback5 = save_feedback(4,4,4, "Data2", @user2, DateTime.civil_from_format(:local, 2021, 2, 16), @team)
    feedback6 = save_feedback(3,3,3, "Data3", @user10, DateTime.civil_from_format(:local, 2021, 2, 16), @team)
    
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url 
    
    assert_text 'Current Week: ' + @week_range[:start_date].strftime('%b %-e, %Y').to_s + " to " + @week_range[:end_date].strftime('%b %-e, %Y').to_s
    assert_text 'Medium'
  end 
  
  def test_professor_summary_team_priority_view_timeperiod_low_status
    #Passes acceptance criteria 3: As a professor, I am able to view overall priority for all team's summary view
    #Case 3, professor should see a team's overall priority as "Low" under team Urgency/Intervention column if the average ratings are at the good end of the scale.
    
    feedback4 = save_feedback(5,5,5, "Data1", @user, DateTime.civil_from_format(:local, 2021, 2, 15), @team)
    feedback5 = save_feedback(5,5,5, "Data2", @user2, DateTime.civil_from_format(:local, 2021, 2, 16), @team)
    feedback6 = save_feedback(4,4,4, "Data3", @user10, DateTime.civil_from_format(:local, 2021, 2, 16), @team)
    
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url 
    
    assert_text 'Current Week: ' + @week_range[:start_date].strftime('%b %-e, %Y').to_s + " to " + @week_range[:end_date].strftime('%b %-e, %Y').to_s
    assert_text 'Low'
  end 
  
end
