require "application_system_test_case"
# Acceptance Criteria:
# 1. Given that a already used team code is used on the create team page,
#    I should not be able to create another team with that code

class CreateTeamValidationTest < ApplicationSystemTestCase
  # Test that Team cannot be created with a already used Team Code (1)
  def test_create_invalid_team
    # create professor 
    User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url

    # create new team
    click_on "Manage Teams"
    find('#new-team-link').click
    
    fill_in "Team name", with: "Test Team"
    fill_in "Team code", with: "Code 1"
    click_on "Create Team"
    assert_text "Team was successfully created."
    click_on "Back"

    click_on "Manage Teams"
    find('#new-team-link').click
    fill_in "Team name", with: "Test Team"
    fill_in "Team code", with: "Code 1"
    click_on "Create Team"
    assert_text "Team code has already been taken"
  end
end