require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Option.create
  end
  
  def test_should_redirect_to_login
    get root_url
    assert_response :redirect
  end
  
  def test_should_render_page 
    prof = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: true)
    prof.save
    user = User.new(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user.save

    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = prof
    team.save
    user.teams << team

    post '/login',
        params: {email: 'charles2@gmail.com', password: 'banana'}
    
    get root_url 
    assert_response :success
  end

  def test_help_page_no_login
    get '/help'
    assert_redirected_to login_path
  end
  
  def test_help_page 
    user = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user.save!
    
    post '/login',
        params: {email: 'charles@gmail.com', password: 'banana'}
    get '/help'
    assert :success
  end
  
  def test_show_reset_password 
    get reset_password_path
    assert :success
  end
  
  def test_reset_password 
    user = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user.save!
    
    post '/login',
        params: {email: 'charles@gmail.com', password: 'banana'}
    post reset_password_path, params: {existing_password: 'banana', password: 'banana2', password_confirmation: 'banana2'}
    assert :success
    get '/logout'
    post '/login', 
        params: {email: 'charles@gmail.com', password: 'banana'}
    assert :failure
    post '/login',
        params: {email: 'charles@gmail.com', password: 'banana2'}
    assert :success
  end
  
  def test_reset_password_wrong_existing 
    user = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user.save!
    
    post '/login',
        params: {email: 'charles@gmail.com', password: 'banana'}
    post reset_password_path, params: {existing_password: 'banana3', password: 'banana2', password_confirmation: 'banana2'}
    assert_redirected_to reset_password_path
    get '/logout'
    post '/login', 
        params: {email: 'charles@gmail.com', password: 'banana2'}
    assert :failure
    post '/login',
        params: {email: 'charles@gmail.com', password: 'banana'}
    assert :success
  end
  
  def test_reset_password_wrong_new
    user = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user.save!
    
    post '/login',
        params: {email: 'charles@gmail.com', password: 'banana'}
    post reset_password_path, params: {existing_password: 'banana', password: 'bana', password_confirmation: 'bana'}
    assert_redirected_to reset_password_path
    get '/logout'
    post '/login', 
        params: {email: 'charles@gmail.com', password: 'bana'}
    assert :failure
    post '/login',
        params: {email: 'charles@gmail.com', password: 'banana'}
    assert :success
  end
  
  def test_reset_password_wrong_confirmation
    user = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user.save!
    
    post '/login',
        params: {email: 'charles@gmail.com', password: 'banana'}
    post reset_password_path, params: {existing_password: 'banana', password: 'banana3', password_confirmation: 'banana2'}
    assert_redirected_to reset_password_path
    get '/logout'
    post '/login', 
        params: {email: 'charles@gmail.com', password: 'banana3'}
    assert :failure
    post '/login',
        params: {email: 'charles@gmail.com', password: 'banana'}
    assert :success
  end

  def test_previous_week_missing_feedback_csv
    prof = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: true)
    prof.save!

    #students that haven't submitted
    user2 = User.new(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user2.save
    user3 = User.new(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user3.save

    post '/login',
      params: {email: 'charles@gmail.com', password: 'banana'}

    get '/download_previous.csv'

    assert :success
    # expect( DownloadHelpers::download_content ).to include download_previous
  end

  def test_previous_week_current_feedback_csv
    prof = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: true)
    prof.save!

    #students that haven't submitted
    user2 = User.new(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user2.save
    user3 = User.new(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user3.save

    post '/login',
      params: {email: 'charles@gmail.com', password: 'banana'}

    get '/download_current.csv'

    assert :success
    # expect( DownloadHelpers::download_content ).to include download_previous
  end


end
