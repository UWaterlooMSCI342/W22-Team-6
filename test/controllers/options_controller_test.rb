require 'test_helper'

class OptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # create test user
    @user = User.new(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    @user.save
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.new(team_code: 'Code2', team_name: 'Team 1')
  end
  
  def test_regenerate_option_code 
    Option.destroy_all 
    Option.create(admin_code: 'test')
    post(login_path, params: { email: 'msmucker@gmail.com', password: 'professor'})
    get regenerate_admin_code_url
    assert_not_equal('test', Option.first.admin_code)
  end 
  
  def test_regenerate_option_code_non_admin 
    Option.destroy_all 
    Option.create(admin_code: 'test')
    post(login_path, params: { email: 'charles@gmail.com', password: 'banana'})
    get regenerate_admin_code_url
    assert_equal('test', Option.first.admin_code)
  end 
end
