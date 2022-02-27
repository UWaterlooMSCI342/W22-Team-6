require "application_system_test_case"
class StudentLinks < ApplicationSystemTestCase
    def setup
      
        @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
        @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
        @user = User.create(email: 'kait@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Kait', last_name: 'Test', is_admin: false, teams: [@team])
      end

    def test_link_name_to_student_profile_home
        visit root_url
        login 'msmucker@gmail.com', 'professor'
        assert_current_path root_url
        click_link(@user.full_name, :match => :prefer_exact)
        assert_current_path user_path(@user)

    end 

    def test_link_name_to_student_profile_manage_teams
        visit root_url
        login 'msmucker@gmail.com', 'professor'
        assert_current_path root_url
        visit teams_url
        assert_current_path teams_url
        click_link(@user.full_name)
        assert_current_path user_path(@user)
    end 

    def test_link_name_to_student_profile_manage_users
        visit root_url
        login 'msmucker@gmail.com', 'professor'
        assert_current_path root_url
        visit users_url
        assert_current_path users_url
        click_link(@user.first_name)
        assert_current_path user_path(@user)
        click_on "Back"
        assert_current_path users_url
        click_link(@user.last_name)
        assert_current_path user_path(@user)
    end 

    def test_link_name_to_student_profile_feedbacks
        feedback = save_feedback(5,5,5, "Week 9 data 1", @user, DateTime.civil_from_format(:local, 2021, 3, 1), @team)
        visit root_url
        login 'msmucker@gmail.com', 'professor'
        assert_current_path root_url
        visit feedbacks_url
        assert_current_path feedbacks_url
        click_on(@user.first_name)
        assert_current_path user_path(@user)
        click_on "Back"
        assert_current_path feedbacks_url
        click_on(@user.last_name)
        assert_current_path user_path(@user)
    end 

    def test_link_name_to_student_profile_feedbacks_for_a_user
        feedback = save_feedback(5,5,5, "Week 9 data 1", @user, DateTime.civil_from_format(:local, 2021, 3, 1), @team)
        visit root_url
        login 'msmucker@gmail.com', 'professor'
        assert_current_path root_url
        visit feedbacks_url
        assert_current_path feedbacks_url
        click_on "Show"
        click_on(@user.full_name)
        assert_current_path user_path(@user)
    end 



end
