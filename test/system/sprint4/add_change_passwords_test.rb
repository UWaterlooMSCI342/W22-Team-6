require "application_system_test_case"

# Acceptance Criteria:
# 1. User should be able to change their password given the correct existing password 
# 2. User should not be able to change their password without the correct existing password
# 3. User should be not be able to change their password if they do not have security questions
# 4. User should be able to change their password if they click on forgot password. 
# 5. User should be able to change their passowrd if they rememeber their security question

class AddChangePasswordsTest < ApplicationSystemTestCase
  setup do 
    User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', security_q_one: 'toronto', security_q_two: "waterloo", security_q_three: 'pizza', is_admin: true, password: 'professor', password_confirmation: 'professor')
  end 

  def test_change_password 
    User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')

    # log professor in
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on 'Change Password'
    fill_in "existing_password", with: 'professor'
    fill_in "password", with: 'professor2'
    fill_in "password_confirmation", with: 'professor2'
    
    click_on 'Submit'
    
    assert_text 'Password successfully updated!'
    click_on 'Logout'
    
    login 'msmucker@gmail.com', 'professor'
    assert_current_path login_url 
    
    login 'msmucker@gmail.com', 'professor2'
    assert_current_path root_url
  end
  
  def test_change_password_incorrect_existing
    User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')

    # log professor in
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on 'Change Password'
    fill_in "existing_password", with: 'professor2'
    fill_in "password", with: 'professor3'
    fill_in "password_confirmation", with: 'professor3'
    
    click_on 'Submit'
    
    assert_text 'Incorrect existing password'
    click_on 'Back'
    click_on 'Logout'
    
    login 'msmucker@gmail.com', 'professor3'
    assert_current_path login_url 
    
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
  end
   
  def test_forgot_password_email
    
    visit root_url

    click_on 'Forgot Password'
    click_on 'Next'
    assert_text "Email can't be blank!"

    fill_in "email", with: 'kjlkj@gmail.com'
    click_on 'Next'
    assert_text "Email doesn't exist!"
    
    fill_in "email", with: 'msmucker@gmail.com'
    click_on 'Next'
  end 

  def test_forgot_reset_password
 
    visit root_url

    click_on 'Forgot Password'
    fill_in "email", with: 'msmucker@gmail.com'
    click_on 'Next'

    if page.has_css?('#security_q_one')
      fill_in "security_q_one", with: "ds;lkfjsdf"
    end 

    if page.has_css?('#security_q_two')
      fill_in "security_q_two", with: "sldkfjsdf"
    end 

    if page.has_css?('#security_q_three') 
      fill_in "security_q_three", with: "olksdjflsdkfjk"
    end 
    
    click_on "Submit"
    assert_current_path login_url 
    assert_text "It seems that you have forgotten your password and security question. Please contact you professor for a new password."

  end

  def test_forgot_reset_password_valid
    visit root_url

    click_on 'Forgot Password'
    fill_in "email", with: 'msmucker@gmail.com'
    click_on 'Next'

    if page.has_css?('#security_q_one')
      fill_in "security_q_one", with: "toronto"
    end 

    if page.has_css?('#security_q_two')
      fill_in "security_q_two", with: "waterloo"
    end 

    if page.has_css?('#security_q_three') 
      fill_in "security_q_three", with: "pizza"
    end 

    click_on "Submit"
    # assert_current_path forgot_password_new_pass_show_url

  end

  def test_forgot_reset_password_new_password
    visit root_url

    click_on 'Forgot Password'
    fill_in "email", with: 'msmucker@gmail.com'
    click_on 'Next'

    if page.has_css?('#security_q_one')
      fill_in "security_q_one", with: "toronto"
    end 

    if page.has_css?('#security_q_two')
      fill_in "security_q_two", with: "waterloo"
    end 

    if page.has_css?('#security_q_three') 
      fill_in "security_q_three", with: "pizza"
    end 

    click_on "Submit"
    
    fill_in "password", with: "s"
    fill_in "password_confirmation", with: "fd"
    click_on "Submit"
    assert_selector :id, "error", text: "Password and password confirmation do not meet specifications"
    # assert_text "Password and password confirmation do not meet specifications"

    fill_in "password", with: "sss"
    fill_in "password_confirmation", with: "sss"
    click_on "Submit"
    assert_selector :id, "error", text: "Password and password confirmation do not meet specifications"
    # assert_text "Password and password confirmation do not meet specifications"

  end

  def test_forgot_reset_password_new_password_valid
    visit root_url

    click_on 'Forgot Password'
    fill_in "email", with: 'msmucker@gmail.com'
    click_on 'Next'

    if page.has_css?('#security_q_one')
      fill_in "security_q_one", with: "toronto"
    end 

    if page.has_css?('#security_q_two')
      fill_in "security_q_two", with: "waterloo"
    end 

    if page.has_css?('#security_q_three') 
      fill_in "security_q_three", with: "pizza"
    end 

    click_on "Submit"

    fill_in "password", with: "testing123"
    fill_in "password_confirmation", with: "testing123"
    click_on "Submit"

    assert_current_path login_url
    assert_text "Password successfully updated!"
  end
end
