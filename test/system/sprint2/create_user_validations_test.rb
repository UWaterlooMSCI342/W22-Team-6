require "application_system_test_case"

#Acceptance criteria
#1) As a user, I cannot create an account with a duplicate email
#2) As a user, I cannot create a student account with an invalid team code
#3) As a user, I cannot create a student account with a duplicate student number
#4) As a user, I cannot create an account with a password less than 6 characters

class CreateUserValidationsTest < ApplicationSystemTestCase
    def setup
      Option.create
      prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
      team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: prof)
      user = User.create(email: 'scottf@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Elon', last_name: 'Musk', is_admin: false, teams: [team])
    end
    #1) As a user, I cannot create an account with a duplicate email
    def test_create_duplicate_user_email
      # register new student
      visit root_url
      click_on "Sign Up"

      fill_in "user[first_name]", with: "Elon"
      fill_in "user[last_name]", with: "Musk"
      fill_in "user[team_code]", with: "TEAM01"
      fill_in "user[email]", with: "SCOTTF@gmail.com"
      fill_in "user[password]", with: "testpassword"
      fill_in "user[password_confirmation]", with: "testpassword"
      click_on "Create account"
      assert_current_path users_url 
    end
    
    def test_create_invalid_user_email
      # register new student
      visit root_url
      click_on "Sign Up"

      fill_in "user[first_name]", with: "Elon"
      fill_in "user[last_name]", with: "Musk"
      fill_in "user[team_code]", with: "TEAM01"
      fill_in "user[email]", with: "scott"
      fill_in "user[password]", with: "testpassword"
      fill_in "user[password_confirmation]", with: "testpassword"
      click_on "Create account"
      assert_current_path users_url 
    end
   
    #2) As a user, I cannot create a student account with an invalid team code
    def test_create_invalid_team_code
      # register new student
      visit root_url
      click_on "Sign Up"

      fill_in "user[first_name]", with: "Elon"
      fill_in "user[last_name]", with: "Musk"
      fill_in "user[team_code]", with: "qwertyu"
      fill_in "user[email]", with: "scottfraser@gmail.com"
      fill_in "user[password]", with: "testpassword"
      fill_in "user[password_confirmation]", with: "testpassword"
      click_on "Create account"
      assert_current_path users_url 
    end
    
    # Criteria 3 deleted since student numbers (user_id) was removed and it is obsolete. 
    
    #4) As a user, I cannot create an account with a password less than 6 characters
    def test_create_invalid_password
      # register new student
      visit root_url
      click_on "Sign Up"

      fill_in "user[first_name]", with: "Elon"
      fill_in "user[last_name]", with: "Musk"
      fill_in "user[team_code]", with: "TEAM01"
      fill_in "user[email]", with: "scottfraser@gmail.com"
      fill_in "user[password]", with: "abcde"
      fill_in "user[password_confirmation]", with: "abcde"
      click_on "Create account"
      assert_current_path users_url 
        
    end
    
    def test_create_valid 
      #valid account
      visit root_url
      click_on "Sign Up"
        
      fill_in "user[first_name]", with: "Elon"
      fill_in "user[last_name]", with: "Musk"
      fill_in "user[team_code]", with: "TEAM01"
      fill_in "user[email]", with: "larry@gmail.com"
      fill_in "user[password]", with: "abcdef"
      fill_in "user[password_confirmation]", with: "abcdef"
      click_on "Create account"
      
      assert_current_path root_url
      assert_text "Welcome, Elon"
    end
end