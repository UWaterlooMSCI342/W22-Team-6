require "application_system_test_case"

# Acceptance Criteria
# 1. GIVEN that I am a user, WHEN I am on my own profile, THEN I should be able to see an "Edit" button.
# 2. GIVEN that I am a user, WHEN I am click on the "Edit" button on my own profile, THEN I should be able to see and fill out a form for editing my information.
# 3. GIVEN that I am a user, WHEN I try accessing someone else's profile, THEN I should be redirected to the home page.
# 4. GIVEN that I am a user, WHEN I try editing my profile with unacceptable information, THEN I should be prompted an error message.

class EditUserTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'password', password_confirmation: 'password')
  end

  def 
end