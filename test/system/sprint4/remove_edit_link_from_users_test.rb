require "application_system_test_case"

class RemoveEditLinkFromUsersTest < ApplicationSystemTestCase
  setup do
    Option.destroy_all
    Option.create(admin_code: 'ADMIN')
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'password', password_confirmation: 'password')
  end
  
  def test_remove_edit_link_for_users
    visit root_url 
    # Login as professor
    login 'msmucker@gmail.com', 'password'

    click_on "Manage Users"
    
    assert_no_text "Edit"
  end
  
end
