require 'test_helper'
require 'date'

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.new(email: 'test@gmail.com', password: '123456789', password_confirmation: '123456789',first_name: 'Elon', last_name: 'Musk', is_admin: false)
    @user2 = User.new(email: 'test2@gmail.com', password: '123456789', password_confirmation: '123456789',first_name: 'Elon', last_name: 'Musk', is_admin: false)
    @user3 = User.new(email: 'test3@gmail.com', password: '123456789', password_confirmation: '123456789', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @user.teams << @team
    @user.save
    @user2.teams << @team
    @user2.save
    @user3.teams << @team
    @user3.save
      
    #create new feedback from student with comment and priority of 2 (low)
    @feedback = Feedback.new(participation_rating: 1, effort_rating: 4, punctuality_rating: 2, comments: "This team is disorganized", priority: 2)
    @feedback.timestamp = @feedback.format_time(DateTime.now)
    @feedback.user = @user
    @feedback.team = @user.teams.first
    
    @feedback.save
  end

  test "should get index prof" do
    #only admin user should be able to see feedbacks
    # login user
    post('/login', params: { email: 'msmucker@gmail.com', password: 'professor'})
    get feedbacks_url
    assert_response :success
  end
  
  test "should not get index student" do
    #students should now have access to the list of feedbacks. It should redirect them back to their homepage!
    post('/login', params: { email: 'test@gmail.com', password: '123456789'})
    get feedbacks_url
    assert_response :redirect
  end 

  test "should get new" do
    Option.create(admin_code: 'ADMIN')
    # login user
    post('/login', params: { email: 'test2@gmail.com', password: '123456789'})
    
    get new_feedback_url
    assert_response :success
  end

  test "should create feedback with default priority" do
    # login user
    post('/login', params: { email: 'test3@gmail.com', password: '123456789'})
    
    assert_difference('Feedback.count') do
        #not passing in a priority value results in default value of 2, which represents low priority
        post feedbacks_url, params: { feedback: { comments: "test comment", participation_rating: 1, effort_rating: 4, punctuality_rating: 2 } }
    end
    assert_redirected_to feedback_url(Feedback.last)
  end
  
  test "should create feedback with selected priority" do
    # login user
    post('/login', params: { email: 'test3@gmail.com', password: '123456789'})
    
    assert_difference('Feedback.count') do
        #student selects a priority of 0, meaning it's urgent
        post feedbacks_url, params: { feedback: { comments: "test comment", participation_rating: 1, effort_rating: 4, punctuality_rating: 2, priority: 0 } }
    end
    assert_redirected_to feedback_url(Feedback.last)
  end

  test "should show feedback" do
    # login professor
    post('/login', params: { email: 'msmucker@gmail.com', password: 'professor'})
    get feedback_url(@feedback)
    assert_response :success
  end

  test "should get edit" do
    # login professor
    post('/login', params: { email: 'msmucker@gmail.com', password: 'professor'})
    get edit_feedback_url(@feedback)
    assert_response :success
  end

  test "should update feedback" do
    # login professor
    post('/login', params: { email: 'msmucker@gmail.com', password: 'professor'})
    patch feedback_url(@feedback), params: { feedback: { comments: "test comment2", participation_rating: 1, effort_rating: 4, punctuality_rating: 2, priority: 1} }
    assert_redirected_to feedback_url(@feedback)
  end

  test "should destroy feedback" do
    # login professor
    post('/login', params: { email: 'msmucker@gmail.com', password: 'professor'})
    assert_difference('Feedback.count', -1) do
      delete feedback_url(@feedback)
    end

    assert_redirected_to feedbacks_url
  end
end
