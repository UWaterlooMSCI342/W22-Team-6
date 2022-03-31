require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    Option.destroy_all
    Option.create(admin_code: 'ADMIN')
    # create test user
    @user = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    @user.save
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', security_q_one: 'toronto', security_q_two: 'waterloo', security_q_three: 'pizza', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.new(team_code: 'Code2', team_name: 'Team 1')
  end
  
  def test_create_user
    # login user
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save  

    student_email = 'scott@gmail.com'
    UserVerification.create(team: team, email: student_email)
    
    post '/users', 
      params: {user: {email: student_email, password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', team_code: 'Code'}}
    assert_redirected_to root_url
  end
  
  def test_create_prof 
    assert_difference('User.count', 1) do 
      post '/users', 
        params: {user: {email: 'prof@gmail.com',first_name: 'Elon', last_name: 'Musk', team_code: 'ADMIN', password: 'professor', password_confirmation: 'professor'}}
      assert_redirected_to root_url 
    end 
    
    prof = User.find_by(email: 'prof@gmail.com')
    assert(prof.is_admin)
  end
  
  # 04/09/2021 for consistency with team code, admin code now case sensitive
  #def test_create_prof_insensitive_code 
  #  assert_difference('User.count', 1) do 
  #    post '/users', 
  #      params: {user: {email: 'prof@gmail.com',first_name: 'Elon', last_name: 'Musk', team_code: 'admIN', password: 'professor', password_confirmation: 'professor'}}
  #    assert_redirected_to root_url 
  #  end 
  #  
  #  prof = User.find_by(email: 'prof@gmail.com')
  #  assert(prof.is_admin)
  #end
    
  def test_create_user_invalid_team
    # login user
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save  
    
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@gmail.com', password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', team_code: 'Code2'}}
      #https://stackoverflow.com/questions/2915939/rails-testing-assert-render-action/38457649
      assert_template :new
    end
  end
  
  def test_create_user_missing_name
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@gmail.com', password: 'banana', password_confirmation: 'banana', team_code: 'Code2'}}
      assert_template :new
    end
  end
    
  def test_create_user_invalid_name
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@gmail.com', password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', user_id: '1010', team_code: 'Code2'}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_student_number
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@gmail.com', password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', team_code: 'Code2'}}
      assert_template :new
    end
  end
  
  def test_create_user_non_unique_student_number
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@gmail.com', password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', team_code: 'Code2'}}
      assert_template :new
    end
  end

  def test_create_user_missing_team_code
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@gmail.com', password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk'}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_email
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: { password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', team_code: 'Code2'}}
      assert_template :new
    end
  end
  #also checks email converts to lowercase
  def test_create_user_non_unique_email
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'Charles@gmail.com', password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', team_code: 'Code2'}}
      assert_template :new
    end
  end
    
  def test_create_user_non_valid_email
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'Charles', password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', team_code: 'Code2'}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_password
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@gmail.com', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', team_code: 'Code2'}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_password_confirmation
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@gmail.com', password: 'banana',first_name: 'Elon', last_name: 'Musk', team_code: 'Code2'}}
      assert_template :new
    end
  end

  def test_temp_password_reset
    get user_temp_password_url(@user.id)
    assert :success
  end

  def test_temp_password_reset_matching_password
    post user_temp_password_reset_url(@user.id),
    params: {temp_pass: "hello234", password: "hello234", password_confirmation: "hello234"}
    assert :success
  end

  def test_temp_password_reset_incorrect
    post user_temp_password_reset_url(@user.id),
      params: {temp_pass: "hello123", password: "hello123", password_confirmation: "hello123"}
    assert :success
    
    post user_temp_password_reset_url(@user.id),
    params: {temp_pass: "hello236", password: "hello234", password_confirmation: "hello237"}
    assert :success
  end 

  def test_create_user_nonmatching_passwords
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@gmail.com', password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', team_code: 'Code2'}}
      assert_template :new
    end
  end
  
  def test_forgot_password

    User.create(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, security_q_one: 'toronto', security_q_two: 'waterloo', security_q_three: 'pizza', password: 'professor', password_confirmation: 'professor')

    post '/forgot_password', 
    params: {email: 'msmucker@gmail.com'}
    assert :success

    post '/forgot_password', 
    params: {email: ''}
    assert :success

    post '/forgot_password', 
    params: {email: 'lsdkfjsdfkj'}
    assert :success
  end 

  def test_create_user_missing_security_question

    User.create(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)

    post '/forgot_password', 
    params: {email: 'charles@gmail.com'}
    assert :success
  end

  def test_forgot_reset_password

    get '/forgot_password/reset',
    params: {email: 'msmucker@gmail.com'}
    assert :success

    get '/forgot_password/reset',
    params: {email: 'charles@gmail.com'}
    assert :success

    post '/forgot_password/reset', 
    params: {email: 'msmucker@gmail.com', security_q_one: 'toronto', security_q_two: 'waterloo'}
    assert :success
    
    post '/forgot_password/reset', 
    params: {email: 'msmucker@gmail.com', security_q_one: 'waterloo', security_q_three: 'pizza'}
    assert :success

    post '/forgot_password/reset', 
    params: {email: 'msmucker@gmail.com', security_q_three: 'pizza', security_q_two: 'waterloo'}
    assert :success

  end

  # def test_forgot_reset_password_page
  #   post '/forgot_password/reset' 
  #   assert_response :success

  #   post '/forgot_password/reset/new_pass'
  #   assert_response :success
  # end

  def test_forgot_reset_password_success

    get '/forgot_password/reset/new_pass', 
    params: {email: 'msmucker@gmail.com'}
    assert :success


    post '/forgot_password/reset/new_pass', 
    params: {email: 'msmucker@gmail.com', password: 'helloo23', password_confirmation: 'helloo23'}
    assert :success
  end

  def test_forgot_reset_password_done_wrong_password
    post '/forgot_password/reset/new_pass', 
    params: {email: 'msmucker@gmail.com', password: 'h', password_confirmation: 'hell3'}
    assert 'Password and password confirmation do not meet specifications'
      
  end

  def test_forgot_reset_password_done_incorrect_password_length
    post '/forgot_password/reset/new_pass', 
    params: {email: 'msmucker@gmail.com', password: 'h', password_confirmation: 'h'}
    assert 'Password and password confirmation do not meet specifications'
  end

  def test_get_signup
    get '/signup'
    assert_response :success
    assert_select 'h1', 'Sign up!'
  end
  

  test "should get index" do
    post('/login', params: { email: 'msmucker@gmail.com', password: 'professor'})
    get users_url
    assert_response :success
  end

  # professor checking a student profile
  test "should show user" do
    post('/login', params: { email: 'msmucker@gmail.com', password: 'professor'})
    get user_url(@user)
    assert_response :success
  end

  #student checking their own profile
  test "should show own user" do
    post('/login', params: { email: 'charles@gmail.com', password: 'banana'})
    get user_url(@user)
    assert_response :success
  end

  #student checking another student's profile
  test "should not show user" do
    @user2 = User.new(email: 'bob@gmail.com', password: 'strawberry', password_confirmation: 'strawberry', first_name: 'Bob', last_name: 'L', is_admin: false)
    @user2.save

    post('/login', params: { email: 'charles@gmail.com', password: 'banana'})
    get user_url(@user2)
    assert_redirected_to root_url
  end

  test "should get edit" do
    post('/login', params: { email: 'msmucker@gmail.com', password: 'professor'})
    get edit_user_url(@prof)
    assert_response :success
  end

  test "should update user" do
    post('/login', params: { email: 'msmucker@gmail.com', password: 'professor'})
    patch user_url(@user), params: { user: { email: @user.email, first_name: @user.first_name, last_name: @user.last_name, password: @user.password, password_confirmation: @user.password_confirmation } }
    assert_redirected_to user_url(@user)
  end
  

  test "should destroy user" do
    post('/login', params: { email: 'msmucker@gmail.com', password: 'professor'})
    assert_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end

    
  def test_delete_student_as_prof
    @generated_code = Team.generate_team_code
    @team = Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, user: @prof)
    @bob = User.create(email: 'bob@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    
    post(login_path, params: { email: 'msmucker@gmail.com', password: 'professor'})
    delete(user_path(@bob.id))
    
    User.all.each { |user| 
        assert_not_equal(@bob.first_name + @bob.first_name, user.first_name + user.last_name)
    }
  end
  
  def test_delete_admin_as_prof
    @ta = User.create(email: 'amir@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: true, password: 'password', password_confirmation: 'password')
    
    post(login_path, params: { email: 'msmucker@gmail.com', password: 'professor'})
    delete(user_path(@ta.id))
    
    User.all.each { |user| 
        assert_not_equal(@ta.first_name + @ta.first_name, user.first_name + user.last_name)
    }
  end
  
  def test_delete_as_student
    @bob = User.create(email: 'bob@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    
    post(login_path, params: { email: 'bob@gmail.com', password: 'testpassword'})
    delete(user_path(@prof.id))
    
    assert_not_nil(User.find_by(email: 'msmucker@gmail.com'))
  end
end
