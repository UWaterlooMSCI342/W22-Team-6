require "application_system_test_case"

# Acceptance Criteria
# 1. As a professor, I have the ability to delete a student user from the app
# 2. As a professor, I have the ability to delete an admin user from the app
# 3. As a student, I do not have the ability to delete any user from the app

class DeleteUserTest < ApplicationSystemTestCase
  setup do
    Option.destroy_all
    Option.create(admin_code: 'ADMIN')
    @generated_code = Team.generate_team_code
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'password', password_confirmation: 'password')
    @team = Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, user: @prof)
  end
  
  #(1)
  def test_delete_astudent_as_prof
    @bob = User.create(email: 'bob@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    
    visit root_url 
    # Login as professor
    login 'msmucker@gmail.com', 'password'
    
    
    click_on "Manage Users"
    
    within('#user' + @bob.id.to_s) do
      assert_text @bob.email
      assert_text(@bob.first_name + " " +  @bob.last_name)
      click_on 'Delete User'
    end
    
    assert_current_path user_confirm_delete_path(@bob)
    click_on "Delete User"

    assert_text "User was successfully destroyed."
    
     User.all.each { |user| 
        assert_not_equal(@bob.first_name + @bob.last_name, user.first_name + user.last_name)
    }
  end
  
  
  #(2)
  def test_delete_admin_as_prof
    @ta = User.create(email: 'amir@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: true, password: 'password', password_confirmation: 'password')
    
    visit root_url 
    # Login as professor
    login 'msmucker@gmail.com', 'password'

    click_on "Manage Users"
    
    within('#user' + @ta.id.to_s) do
      assert_text @ta.email
      assert_text (@ta.first_name + " " + @ta.last_name)
      click_on 'Delete User'
    end
    
    assert_current_path user_confirm_delete_path(@ta)
    click_on "Delete User"
    
    assert_text "User was successfully destroyed."
    
     User.all.each { |user| 
        assert_not_equal(@ta.first_name + " " + @ta.last_name, user.first_name + user.last_name)
    }
  end
  
    #(3)
  def test_delete_as_student
    @bob = User.create(email: 'bob@gmail.com',first_name: 'Elon', last_name: 'Musk', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    
    visit root_url 
    # Login as professor
    login 'bob@gmail.com', 'testpassword'

    visit users_path
    
    assert_current_path root_url
    assert_selector :id, "error", text: "You do not have Admin permissions."
    # assert_text "You do not have Admin permissions."
  end

end
