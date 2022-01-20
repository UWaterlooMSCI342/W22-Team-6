require "application_system_test_case"

# Acceptance Criteria:
# 1. Given a correct email and password are entered, when I click login, 
#    I should be redirected to the appropriate page
# 2. Given an incorrect email and password is entered, when I click login,
#    I should be redirected to the login page to try again 
# 3. Given I am not logged in, I should not be able to access any page 
#    other than the registration page or the login page
# 4. Given I am not an admin, I should not be able to access any pages that 
#    are restricted to admins only

class LoginPortalUnvalidatedsTest < ApplicationSystemTestCase
  # (1)
  def test_login 
    prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: prof)
    bob = User.create(email: 'bob@gmail.com', name: 'Bob', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    bob.teams << team
    
    # login with valid credentials
    visit root_url 
    login 'bob@gmail.com', 'testpassword'
    assert_current_path root_url
    
    visit login_url 
    assert_current_path root_url
    
    visit signup_url 
    assert_current_path root_url 
    
    # test urls to see if they can be accessed 
    urls = [new_report_url, new_feedback_url]
    
    for url in urls
      visit url
      assert_current_path url
    end
  end
  
  # Test login with invalid credentials (2, 3)
  def test_invalid_login
    # login with invalid credentials
    visit root_url 
    login 'bad@gmail.com', 'bad'
    assert_current_path login_url 
    
    # test urls to see if they can be accessed without logging in
    urls = [users_url, teams_url, 
            new_team_url, new_feedback_url, 
            feedbacks_url, reports_url,
            new_report_url]
    
    for url in urls
      visit url
      assert_current_path login_url 
    end
  end
  
  # Test admin security as student (4)
  def test_admin_security 
    # SPRINT 2 UPDATE: Since students are now able to see reports they were involved in, this test has been modified to allow reports_url to be accessed without admin status.
    
    # login as student 
    prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: prof)
    bob = User.create(email: 'bob@gmail.com', name: 'Bob', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    bob.teams << team
    visit root_url 
    login 'bob@gmail.com', 'testpassword'
    assert_current_path root_url 
    
    # test urls to see if they can be accessed without admin status
    #students are allowed to access team#show
    urls = [new_team_url, feedbacks_url]
    
    for url in urls
      visit url
      assert_current_path root_url
    end
    
    # log student out
    visit root_url
    click_on "Logout"
    
    # login as admin
    visit root_url 
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url 
    
    # test urls to see if they can be accessed without admin status
      
    urls = [new_team_url, teams_url, feedbacks_url, reports_url]
    
    for url in urls
      visit url
      assert_current_path url
    end
  end    
end
