require "application_system_test_case"

# Acceptance Criteria
# 1. Team's code should be displayed during team edit 

class FixTeamCodeDisplaysTest < ApplicationSystemTestCase
  setup do 
    @prof = User.new(email: 'msmucker@gmail.com', password: 'professor', password_confirmation: 'professor', first_name: 'Mark', last_name: 'Smucker', is_admin: true)
    @prof.save
    @user1 = User.new(email: 'adam@gmail.com', password: '123456789', password_confirmation: '123456789',first_name: 'Elon', last_name: 'Musk', is_admin: false)
    @user1.save

    @team1 = Team.new(team_code: 'ABCDEF', team_name: 'Team 1')
    @team1.user = @prof
    @team1.save
    @user1.teams << @team1
  end
  
  def test_display_team_code 
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url

    click_on 'Manage Teams'
    assert_current_path teams_url
    
    within('#team' + @team1.id.to_s) do
      click_on 'Edit'
    end
    
    # https://www.rubydoc.info/github/jnicklas/capybara/Capybara%2FNode%2FMatchers:has_field%3F
    assert has_field?('Team code', with: @team1.team_code)
    
    click_on 'Update Team'
    
    assert_text 'Team was successfully updated'
    assert_equal('ABCDEF', @team1.team_code)
    assert_equal('Team 1', @team1.team_name)
  end
end
