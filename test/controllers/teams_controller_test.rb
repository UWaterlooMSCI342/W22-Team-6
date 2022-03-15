require 'test_helper'

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Option.create(reports_toggled: true)
    # create test admin
    @prof = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: true)
    @prof.save
    @user = User.new(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    @user.save

    @team = Team.new(team_code: 'Code', team_name: 'Team 1')
    @team.user = @prof
    @team.save
    @user.teams << @team
    # login user
    post('/login', params: { email: 'charles@gmail.com', password: 'banana'})
      assert_redirected_to root_url
  end

  test "should get index" do
    get teams_url
    assert_response :success
  end

  test "should get new" do
    get new_team_url
    assert_response :success
  end

  test "should create team" do
    assert_difference('Team.count', 1) do
      post teams_url, params: { team: { team_code: 'Code2', team_name: 'asdf' } }
    end

    assert_redirected_to team_url(Team.last)
  end

  test "should show team" do
    save_feedback(5,4,3, 'test', @user, Time.zone.now, @team)
    
    get team_url(@team)
    assert_response :success
  end
  
  def test_should_not_show_team 
    get '/logout'
    
    user2 = User.new(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user2.save
    
    post('/login', params: { email: 'charles3@gmail.com', password: 'banana'})
    get team_url(@team)
    assert_redirected_to root_url
  end

  test "should get edit" do
    get edit_team_url(@team)
    assert_response :success
  end

  test "should update team" do
    patch team_url(@team), params: { team: { team_code: @team.team_code, team_name: @team.team_name } }
    assert_redirected_to teams_url
  end

  test "should destroy team no feedback" do
    assert_difference('Team.count', -1) do
      delete team_url(@team)
    end

    assert_redirected_to teams_url
  end
  
  def test_student_cannot_destroy_team 
    get('/logout')
    post('/login', params: { email: 'charles2@gmail.com', password: 'banana'})
    
    assert_difference('Team.count', 0) do
      delete team_url(@team)
    end

    assert_redirected_to root_url
  end
  
  def test_should_destroy_team_with_feedback
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team2.user = @prof
    team2.save
    
    user2 = User.new(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user2.teams = [team2]
    user2.save
    
    feedback = save_feedback(5,3,4, "This team is disorganized", @user, DateTime.civil_from_format(:local, 2021, 3, 1), @team)
    feedback2 = save_feedback(5,5,3, "This team is disorganized", @user, DateTime.civil_from_format(:local, 2021, 3, 3), @team)
    feedback3 = save_feedback(5,4,3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team2)

    assert_difference('Team.count', -1) do 
      delete team_url(@team)
    end 

    assert_equal(1, Feedback.count)
    Feedback.all.each do |feedback|
      assert_equal(feedback3, feedback)
    end
  end
    
  def test_create_team_invalid_code
    assert_no_difference 'Team.count' do
      post '/teams', 
        params: {team: {team_name: "Team 3", team_code: 'qwertyuiopasdfghjklzxcvbnmq'}}
      get new_team_url
    end
  end
    
  def test_create_team_invalid_name
    assert_no_difference 'Team.count' do
      post '/teams', 
        params: {team: {team_name: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", team_code: 'qwerty'}}
      get new_team_url
    end
  end

  def test_create_team_blank_code
    assert_difference 'Team.count' do
      post '/teams', 
        params: {team: {team_name: "Team 3", team_code: ''}}
      get new_team_url
    end
  end
    
  def test_create_team_blank_name
    assert_no_difference 'Team.count' do
      post '/teams', 
        params: {team: {team_name: "", team_code: 'qwerty'}}
      get new_team_url
    end
  end
  
  def test_help_page
    get '/team_view/help'
    assert :success
  end

  #Also test downcase
  def test_create_team_duplicate_code
    assert_no_difference 'Team.count' do
      post '/teams', 
        params: {team: {team_name: "Team 3", team_code: 'code'}}
      get new_team_url
    end
  end

  test "should allow student access to their teams view" do
    # logout admin
    get '/logout'
    # login to user account
    post('/login', params: { email: 'charles2@gmail.com', password: 'banana'})

    get team_url(@team)
    assert_response :success
    post('/login', params: { email: 'charles@gmail.com', password: 'banana'}) 
  end
  
  def test_delete_user_from_team_as_prof
    post(login_path, params: { email: 'msmucker@gmail.com', password: 'professor'})
    post team_remove_user_from_team_path(user_id: @user.id, team_id: @team.id)
    assert_equal([], @team.users)
  end
  
  def test_delete_user_from_team_as_student
    post(login_path, params: { email: 'charles2@gmail.com', password: 'banana'})
    post team_remove_user_from_team_path(user_id: @user.id, team_id: @team.id)
    assert_not_equal([], @team.users)
  end
end
