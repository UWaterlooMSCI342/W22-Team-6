require "application_system_test_case"

# Acceptance Criteria: 
# 1. When I submit the feedback form, all the input data should be added to
#    the database
# 2. When I select the rating dropdown, all the appropriate ratings should
#    appear
# 3. When I submit the feedback form, the data shold be associated with my 
#    team in the database

class CreateFeedbackFormUnvalidatedsTest < ApplicationSystemTestCase
  setup do
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @bob = User.create(email: 'bob@gmail.com', name: 'Bob', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
  end
  
  # Test that feedback can be added using correct form (1, 2)
  def test_add_feedback 
    visit root_url 
    login 'bob@gmail.com', 'testpassword'    
    
    click_on "Submit for"
    assert_current_path new_feedback_url
    assert_text "Your Current Team: Test Team"
    
    select "5", from: "Participation rating"
    select "3", from: "Effort rating"
    select "1", from: "Punctuality rating"
    select "Urgent", from: "Priority"
    fill_in "Comments", with: "This week has gone okay."
    click_on "Create Feedback"
    
    assert_current_path root_url
    
    Feedback.all.each{ |feedback| 
      assert_equal(5 , feedback.participation_rating)
      assert_equal(3 , feedback.effort_rating)
      assert_equal(1 , feedback.punctuality_rating)
      assert_equal(0 , feedback.priority)
      assert_equal('This week has gone okay.', feedback.comments)
      assert_equal(@bob, feedback.user)
      assert_equal(@team, feedback.team)
    }
  end
  
  # Test that feedback that is added can be viewed (1, 3)
  def test_view_feedback 
    feedback = Feedback.new(participation_rating: 1, effort_rating: 5, punctuality_rating: 2, comments: "This team is disorganized", priority: 0)
    datetime = Time.current
    feedback.timestamp = feedback.format_time(datetime)
    feedback.user = @bob
    feedback.team = @bob.teams.first
    feedback.save
    
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    
    click_on "Details"
    assert_current_path team_url(@team)
    assert_text "This team is disorganized"
    assert_text "1"
    assert_text "5"
    assert_text "2"
    assert_text "Urgent"
    assert_text "Test Team"
    assert_text datetime.strftime("%Y-%m-%d %H:%M")
  end
end
