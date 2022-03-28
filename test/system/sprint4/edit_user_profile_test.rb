require "application_system_test_case"

# Acceptance Criteria
# 1. GIVEN that I am a user, WHEN I am on my own profile, THEN I should be able to see an "Edit" button.
# 2. GIVEN that I am a user, WHEN I am click on the "Edit" button on my own profile, THEN I should be able to see and fill out a form for editing my information.
# 3. GIVEN that I am a user, WHEN I try accessing someone else's profile, THEN I should be redirected to the home page.
# 4. GIVEN that I am a user, WHEN I try editing my profile with unacceptable information, THEN I should be prompted an error message.

class EditUserTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'password', password_confirmation: 'password')
    @user = User.create(email: 'test@gmail.com', first_name: 'Test', last_name: 'Student', is_admin: false, password: 'password', password_confirmation: 'password')
  end

  def test_edit_own_profile_as_prof
    visit root_url
    login 'msmucker@gmail.com', 'password'

    visit user_url(@prof)

    click_on 'Edit'

    assert_text 'Edit Profile'

    # could check for prepopulated text fields here

    fill_in 'First name', with: 'newFirstName'
    fill_in 'Last name', with: 'newLastName'
    fill_in 'Email', with: 'newEmail@email.com'
    click_on 'Update account'

    assert_text 'User was successfully updated.'
    assert_current_path user_url(@prof)
    assert_text 'newemail@email.com'
    assert_text 'newFirstName'
    assert_text 'newLastName'
  end

  def test_edit_own_profile_as_student
    visit root_url
    login 'test@gmail.com', 'password'

    visit user_url(@user)

    click_on 'Edit'

    assert_text 'Edit Profile'

    # could check for prepopulated text fields here

    fill_in 'First name', with: 'newFirstName'
    fill_in 'Last name', with: 'newLastName'
    fill_in 'Email', with: 'newEmail@email.com'
    click_on 'Update account'

    assert_text 'User was successfully updated.'
    assert_current_path user_url(@user)
    assert_text 'newemail@email.com'
    assert_text 'newFirstName'
    assert_text 'newLastName'
  end

  def test_edit_someone_elses_profile_as_prof
    visit root_url
    login 'msmucker@gmail.com', 'password'

    visit edit_user_url(@user)
    assert_text 'You do not have permission to edit someone else\'s profile.'
  end

  def test_edit_someone_elses_profile_as_student
    visit root_url
    login 'test@gmail.com', 'password'

    visit edit_user_url(@prof)
    assert_text 'You do not have permission to edit someone else\'s profile.'
  end

  def test_invalid_edit
    visit root_url
    login 'msmucker@gmail.com', 'password'

    visit user_url(@prof)

    click_on 'Edit'

    assert_text 'Edit Profile'

    # could check for prepopulated text fields here

    fill_in 'First name', with: ''
    fill_in 'Last name', with: ''
    fill_in 'Email', with: ''
    click_on 'Update account'

    assert_text 'First name can\'t be blank'
    assert_text 'Last name can\'t be blank'
    assert_text 'Email can\'t be blank'
  end
end