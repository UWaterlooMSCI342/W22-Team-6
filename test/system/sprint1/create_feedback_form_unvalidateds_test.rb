require "application_system_test_case"

# Acceptance Criteria: 
# 1. When I submit the feedback form, all the input data should be added to
#    the database
# 2. When I select the rating dropdown, all the appropriate ratings should
#    appear
# 3. When I submit the feedback form, the data shold be associated with my 
#    team in the database
# 4. Student edits their feedback.
# 5. Student tries editing feedback that is not their own.

class CreateFeedbackFormUnvalidatedsTest < ApplicationSystemTestCase
  setup do
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @bob = User.create(email: 'bob@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
  end
  
  # Test that feedback can be added using correct form (1, 2)
  def test_add_feedback 
    visit root_url 
    login 'bob@gmail.com', 'testpassword'    
    
    click_on "Submit for"
    assert_current_path new_feedback_url
    assert_text "Your Current Team: Test Team"
    
    select "3", from: "Participation rating"
    select "3", from: "Effort rating"
    select "1", from: "Punctuality rating"
    fill_in "Comments", with: "This week has gone okay."
    click_on "Create Feedback"
    
    assert_current_path feedback_url(Feedback.last)
    visit root_url
    
    Feedback.all.each{ |feedback| 
      assert_equal(3 , feedback.participation_rating)
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
    
    within('#' + @team.id.to_s) do
      click_on @team.team_name
    end
    assert_current_path team_url(@team)
    assert_text "This team is disorganized"
    assert_text "1"
    assert_text "5"
    assert_text "2"
    assert_text "High"
    assert_text "Test Team"
    assert_text datetime.strftime("%Y-%m-%d %H:%M")
  end

  def test_create_and_edit_own_feedback
    visit root_url
    login 'bob@gmail.com', 'testpassword'

    # Create own feedback.
    click_on "Submit for"
    assert_current_path new_feedback_url
    assert_text "Your Current Team: Test Team"

    select "1", from: "Participation rating"
    select "1", from: "Effort rating"
    select "1", from: "Punctuality rating"
    fill_in "Comments", with: "I will edit this feedback."
    click_on "Create Feedback"
    assert_current_path feedback_url(Feedback.last)
    assert_text "Participation Rating: 1"
    assert_text "Effort Rating: 1"
    assert_text "Punctuality Rating: 1"
    assert_text "Priority Level: High"
    assert_text "Comments: I will edit this feedback."
    visit root_url #go back to home page

    # Edit feedback that was just created.
    click_on "Edit Rating"
    assert_current_path edit_feedback_url(Feedback.last)
    assert_text "Your Current Team: Test Team"

    select "5", from: "Participation rating"
    select "5", from: "Effort rating"
    select "5", from: "Punctuality rating"
    fill_in "Comments", with: "I edited this feedback."
    click_on "Update Feedback"

    # Confirm feedback was correctly updated.
    assert_current_path feedback_url(Feedback.last)
    assert_text "Participation Rating: 5"
    assert_text "Effort Rating: 5"
    assert_text "Punctuality Rating: 5"
    assert_text "Priority Level: Low"
    assert_text "Comments: I edited this feedback."
  end

  def test_try_editing_another_user_feedback
    # Create other user with feedback that will try to be accessed.
    other_user = User.create(email: 'fred@gmail.com', password: 'testpassword', password_confirmation: 'testpassword', first_name: 'Fred', last_name: 'F', is_admin: false)
    other_user.teams << @team
    feedback = save_feedback(1,1,1, "Other user's feedback.", other_user, DateTime.now, @team)

    visit root_url
    login 'bob@gmail.com', 'testpassword'

    # Redirect when attempting to access other user's feedback.
    visit edit_feedback_path(Feedback.last)
    assert_current_path root_url
    assert_text "You do not have permission to access this feedback."
  end

  def test_viewing_own_feedback_not_from_this_week
    # Create own feedback that will try to be accessed.
    feedback = save_feedback(1,1,1, "Feedback from a while ago.", @bob, DateTime.civil_from_format(:local, 2021, 1, 20), @team)

    visit root_url
    login 'bob@gmail.com', 'testpassword'

    # Redirect when attempting to access own feedback not from this week.
    visit edit_feedback_path(Feedback.last)
    assert_current_path root_url
    assert_text "You do not have permission to access this feedback."
  end
end
