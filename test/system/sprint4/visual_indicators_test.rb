require "application_system_test_case"

# Acceptance Criteria:
# 1: As a professor, I should be able to see colored indicators for team summary and detailed views
# 2: As a student, I should be able to see colored indicators for team summary and detailed views

class VisualIndicatorsTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: true)
    @prof2 = User.create(email: 'msmucker@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Mark', last_name: 'Smucker', is_admin: true)
    @user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana',first_name: 'Elon', last_name: 'Musk', is_admin: false)

    @user1.save!
    @user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Olivera', is_admin: false)
    @user2.save!
    @user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Olivera', is_admin: false)
    @user3.save!

    @team = Team.new(team_code: 'Code', team_name: 'Team 1')
    @team.users = [@user1, @user2]
    @team2 = Team.new(team_code: 'Test', team_name: 'Test 2')
    @team2.users = [@user3]

    @team.user = @prof 
    @team.save!
    @team2.user = @prof2
    @team2.save!

    @feedback = save_feedback(1,1,1, "This team is disorganized", @user1, DateTime.civil_from_format(:local, 2021, 1, 20) - 7, @team)
    @feedback2 = save_feedback(5,5,5, "This team is disorganized", @user2, DateTime.civil_from_format(:local, 2021, 1, 20), @team)
    @feedback3 = save_feedback(5,5,5, "This team is disorganized", @user1, DateTime.civil_from_format(:local, 2021, 1, 20), @team)
    @feedback4 = save_feedback(1,1,1, "This team is disorganized", @user3, DateTime.now, @team2)
  
  end 
  
  # The current week hasn't been submitted.
  def test_student_view_no_submission_on_current_week 
    visit root_url 
    login 'charles2@gmail.com', 'banana'
  
    # We have a blue status. 
    within('#' + @user1.id.to_s + '-status') do
      assert find('.dot.blue')
    end
    
    click_on 'View Historical Data'

    within('#2021-3') do 
      assert find('.dot.green')
    end
    within('#2021-2') do 
      assert find('.dot.red')
    end
  end

  # The current week has now been submitted. 
  def test_student_view_submission_on_current_week
    visit root_url 
    login 'charles4@gmail.com', 'banana'

    within('#' + @user3.id.to_s + '-status') do
      assert find('.dot.red')
    end
    
  end
  
  def test_professor_view 
    visit root_url 
    login 'charles@gmail.com', 'banana'
    
    within('#' + @team.id.to_s) do 
      assert find('.dot.red')
    end 
    
    click_on 'Details', match: :first
    
    within('#2021-3') do 
      assert find('.dot.green')
    end
    within('#2021-2') do 
      assert find('.dot.red')
    end
  end
end
