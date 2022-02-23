require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a professor, I should be able to see team summary of latest period
# 2. As a professor, I should be able to see detailed team ratings 
#    for specific teams based on time periods

class GroupFeedbackByPeriodsTest < ApplicationSystemTestCase
  include FeedbacksHelper
  
  setup do 
    @week_range = week_range(2021, 7)
    #sets the app's date to week of Feb 15 - 21, 2021 for testing
    travel_to Time.new(2021, 02, 15, 06, 04, 44)
  end 
  
  # (1)
  def test_team_summary_by_period
    prof = User.create(email: 'msmucker@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Mark Smucker', is_admin: true)
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = prof 
    team.save!
    
    feedback1 = save_feedback(4, 5, 1, "Data1", user1, DateTime.civil_from_format(:local, 2021, 02, 15), team)
    feedback2 = save_feedback(3, 3, 3, "Data2", user2, DateTime.civil_from_format(:local, 2021, 02, 16), team)
    
    average_rating1 = ((4+3).to_f/2).round(2)
    average_rating2 = ((5+3).to_f/2).round(2)
    average_rating3 = ((1+3).to_f/2).round(2)
    
    visit root_url 
    login 'msmucker@gmail.com', 'banana'
    assert_current_path root_url 
    
    assert_text 'Current Week: ' + @week_range[:start_date].strftime('%b %e, %Y').to_s + " to " + @week_range[:end_date].strftime('%b %e, %Y').to_s
    assert_text average_rating1.to_s
    assert_text average_rating2.to_s
    assert_text average_rating3.to_s  
  end 
  
  # (2)
  def test_view_by_period
    prof = User.create(email: 'msmucker@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Mark Smucker', is_admin: true)
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = prof 
    team.save!

    feedback = save_feedback(5, 5, 5, "Week 7 data 1", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team)
    feedback2 = save_feedback(4, 4, 4, "Week 7 data 2", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team)
    feedback3 = save_feedback(3, 3, 3, "Week 9 data 1", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    feedback4 = save_feedback(2, 2, 2, "Week 9 data 2", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team)
    
    average_rating_1 = ((5+4).to_f/2).round(2)
    average_rating_2 = ((3+2).to_f/2).round(2)
    
    visit root_url 
    login 'msmucker@gmail.com', 'banana'
    assert_current_path root_url 
    
    within('#' + team.id.to_s) do
      click_on team.team_name
    end
    assert_current_path team_path(team)
    within('#2021-7') do
      assert_text 'Feb 15, 2021 to Feb 21, 2021'
      assert_text 'Avg. Participation Rating of Period (Out of 5): ' + average_rating_1.to_s
      assert_text 'Avg. Effort Rating of Period (Out of 5): ' + average_rating_1.to_s
      assert_text 'Avg. Punctuality Rating of Period (Out of 5): ' + average_rating_1.to_s
      assert_text 'Week 7 data 1'
      assert_text 'Week 7 data 2'
      assert_text '2021-02-15'
      assert_text '2021-02-16'
    end
    within('#2021-9') do
      assert_text 'Mar 1, 2021 to Mar 7, 2021'
      assert_text 'Avg. Participation Rating of Period (Out of 5): ' + average_rating_2.to_s
      assert_text 'Avg. Effort Rating of Period (Out of 5): ' + average_rating_2.to_s
      assert_text 'Avg. Punctuality Rating of Period (Out of 5): ' + average_rating_2.to_s
      assert_text 'Week 9 data 1'
      assert_text 'Week 9 data 2'
      assert_text '2021-03-01'
      assert_text '2021-03-03'
    end
  end
end
