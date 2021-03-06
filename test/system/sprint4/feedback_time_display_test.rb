require "application_system_test_case"

# Acceptance Criteria:
# 1. As student, I should be able to see the time I have started a feedback
# 2. As a student, I should be able to see the time that I have submitted a feedback

class FeebackTimeDisplayTest < ApplicationSystemTestCase
  setup do
    @user = User.new(email: 'test@gmail.com', password: 'asdasd', password_confirmation: 'asdasd',first_name: 'Elon', last_name: 'Musk', is_admin: false)
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @user.teams << @team
    @user.save
      
    # Time.zone = 'Pacific Time (US & Canada)'

    datetime =  Time.zone.parse("2021-3-21 23:30:00")
    feedback_time = Time.zone.parse("2021-3-20 23:30:00")
    travel_to datetime
  end 
    
  def test_time_displays
    visit root_url
    login 'test@gmail.com', 'asdasd'
    assert_current_path root_url
    
    click_on "Submit for"
    assert_text "Current System Time: 2021/03/21 23:30" #Acceptance criteria #1
    select 5, :from => "Participation rating"
    select 5, :from => "Effort rating"
    select 5, :from => "Punctuality rating"
    click_on "Create Feedback"
    assert_current_path feedback_url(Feedback.last)
    assert_text "Feedback was successfully created. Time created: 2021-03-21 23:30 EST" #Acceptance criteria #2
  end 

end
