require 'test_helper'
require 'date'
class TeamTest < ActiveSupport::TestCase
    include FeedbacksHelper
    
    setup do
        @prof = User.create(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: true)
    end

    def test_unique_team_code_admin
      Option.destroy_all
      Option.create(reports_toggled: true, admin_code: 'admin')
      
      team2 = Team.new(team_code: 'admin', team_name: 'Team 2')
      team2.user = @prof
      assert_not team2.valid?
    end 
  
    def test_add_students
        # create test admin
        user = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: false)
        user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: false)
       

        team = Team.new(team_code: 'Code', team_name: 'Team 1')
        team.user = @prof
        team.users = [user, user2]
        assert_difference('Team.count', 1) do
            team.save
        end
    end

    def test_create_team_invalid_team_code
        team = Team.new(team_code: 'Code', team_name: 'Team 1')
        team.user = @prof
        team.save!
        # try creating team with another team with same team code
        # test case insensitive
        team2 = Team.new(team_code: 'code', team_name: 'Team 2')
        team2.user = @prof
        assert_not team2.valid?
    end

    def test_create_team_blank_team_code
        team = Team.new(team_code: 'Code', team_name: 'Team 1')
        team.user = @prof
        team.save!
        # try creating team with blank code
        team2 = Team.new(team_name: 'Team 2')
        team2.user = @prof
        assert_not team2.valid?
    end
    
    def test_create_team_blank_team_name
        team = Team.new(team_code: 'Code', team_name: 'Team 1')
        team.user = @prof
        team.save!
        # try creating team with blank name
        team2 = Team.new(team_code: 'Code2')
        team2.user = @prof
        assert_not team2.valid?
    end
    
    def test_add_students_to_team
        user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: false)
        user1.save!
        team = Team.new(team_code: 'Code', team_name: 'Team 1')
        team.user = @prof
        team.save!
        assert_difference("team.users.count", + 1) do
            team.users << user1
            team.save!
        end
    end

  def test_create_user_invalid_team_duplicate
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save!
    # try creating team with another team with same team code
    team2 = Team.new(team_code: 'Code', team_name: 'Team 2')
    team2.user = @prof
    assert_not team2.valid?
  end
  
  def test_create_user_invalid_team_code
    # too long of a code
    team2 = Team.new(team_code: 'qwertyuiopasdfghjklzxcvbnmq', team_name: 'Team 2')
    team2.user = @prof
    assert_not team2.valid?
  end

  def test_create_user_invalid_team_name
    # too long of a name
    team2 = Team.new(team_code: 'qwerty', team_name: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
    team2.user = @prof
    assert_not team2.valid?
  end
    
  def test_add_students_to_team
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: false)
    user1.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save!
    assert_difference("team.users.count", + 1) do
      team.users << user1
      team.save!
    end
  end

  def test_get_student_names
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.users = [user1, user2]
    team.save!

    students = team.student_names
    students.sort!
    assert_equal ['Charles1', 'Charles2'], students
  end

  def test_average_participation_rating_many_feedbacks
    user = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!

    ratings_participation = [5, 4, 2, 4, 5]
    feedbacks = []
    ratings_participation.each do |participation_rating|
      feedbacks << save_feedback(participation_rating, 1, 1, "None", user, DateTime.now, team)
    end 

    average_rating = Team.average_participation_rating(feedbacks)
    assert_equal(4.0, average_rating)
  end

  def test_average_participation_rating_single_feedback
    user = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!
    
    single_feedback = [save_feedback(3, 1, 1, "None", user, DateTime.now, team)]
    average_rating = Team.average_participation_rating(single_feedback)
    assert_equal(3.0, average_rating)
  end

  def test_average_participation_rating_no_feedback
    feedbacks = []
    average_rating = Team.average_participation_rating(feedbacks)
    assert_nil(average_rating)
  end

  def test_average_effort_rating_many_feedbacks
    user = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!

    ratings_effort = [5, 4, 2, 4, 5]
    feedbacks = []
    ratings_effort.each do |ratings_effort|
      feedbacks << save_feedback(1, ratings_effort, 1, "None", user, DateTime.now, team)
    end 

    average_rating = Team.average_effort_rating(feedbacks)
    assert_equal(4.0, average_rating)
  end

  def test_average_effort_rating_single_feedback
    user = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!
    
    single_feedback = [save_feedback(1, 3, 1, "None", user, DateTime.now, team)]
    average_rating = Team.average_effort_rating(single_feedback)
    assert_equal(3.0, average_rating)
  end

  def test_average_effort_rating_no_feedback
    feedbacks = []
    average_rating = Team.average_effort_rating(feedbacks)
    assert_nil(average_rating)
  end

  def test_average_punctuality_rating_many_feedbacks
    user = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!

    ratings_punctuality = [5, 4, 2, 4, 5]
    feedbacks = []
    ratings_punctuality.each do |ratings_punctuality|
      feedbacks << save_feedback(1, 1, ratings_punctuality, "None", user, DateTime.now, team)
    end 

    average_rating = Team.average_punctuality_rating(feedbacks)
    assert_equal(4.0, average_rating)
  end

  def test_average_punctuality_rating_single_feedback
    user = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!
    
    single_feedback = [save_feedback(1, 1, 3, "None", user, DateTime.now, team)]
    average_rating = Team.average_punctuality_rating(single_feedback)
    assert_equal(3.0, average_rating)
  end

  def test_average_punctuality_rating_no_feedback
    feedbacks = []
    average_rating = Team.average_punctuality_rating(feedbacks)
    assert_nil(average_rating)
  end
  
  def test_feedback_by_period_no_feedback 
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save! 
    
    assert_nil(team.feedback_by_period)
  end
  
  def test_feedback_by_period_one_period
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team.user = @prof 
    team.save!     
    
    feedback = save_feedback(5,5,5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    feedback2 = save_feedback(3,3,3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team)
    
    periods = team.feedback_by_period 
    assert_equal({year: 2021, week: 9}, periods[0][0])
    assert_includes( periods[0][1], feedback )
    assert_includes( periods[0][1], feedback2 )
    assert_equal( 2, periods[0][1].length )
  end
  
  def test_feedback_by_period_multi_period
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team.user = @prof 
    team.save!     
    
    feedback = save_feedback(5,4,2, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    feedback2 = save_feedback(5,5,5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team)
    feedback3 = save_feedback(4,4,4, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team)
    feedback4 = save_feedback(5,5,5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team)
    
    periods = team.feedback_by_period 
    assert_equal({year: 2021, week: 9}, periods[0][0])
    assert_equal({year: 2021, week: 7}, periods[1][0])
    assert_includes( periods[0][1], feedback )
    assert_includes( periods[0][1], feedback2 )
    assert_includes( periods[1][1], feedback3 )
    assert_includes( periods[1][1], feedback4 )
    assert_equal( 2, periods[0][1].length )
    assert_equal( 2, periods[1][1].length )
  end

  def test_calculate_overall_priority_no_users 
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!     

    team_priority = team.calculate_overall_priority(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_nil(team_priority)
  end
  
  def test_calculate_overall_priority_no_feedback_with_users
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof
    team.save!

    team_priority = team.calculate_overall_priority(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal(0, team_priority)
  end

  def test_calculate_overall_priority_when_all_users_submit_with_high_average_ratings
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2, user3]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(5, 5, 5, "I submitted", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(5, 5, 5, "I submitted", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    feedback3 = save_feedback(5, 5, 5, "I submitted", user3, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    team_priority = team.calculate_overall_priority(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal(2, team_priority)
  end
  
  def test_calculate_overall_priority_when_less_than_half_of_team_does_not_submit
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2, user3]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(5, 5, 5, "I submitted", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(5, 5, 5, "I submitted", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    team_priority = team.calculate_overall_priority(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal(1, team_priority)
  end
  
  def test_calculate_overall_priority_when_okay_average_rating
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(3, 3, 3, "This team is okay", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(3, 3, 3, "This team is okay", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    team_priority = team.calculate_overall_priority(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal(1, team_priority)
  end

  def test_calculate_overall_priority_when_more_than_half_of_team_does_not_submit
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(5, 5, 5, "I have a Low priority", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team)\

    team_priority = team.calculate_overall_priority(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal(0, team_priority)
  end

  def test_calculate_overall_priority_when_one_member_submits_high_priority
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(1, 1, 1, "I have a High priority", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(5, 5, 5, "I have a Low priority", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    team_priority = team.calculate_overall_priority(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal(0, team_priority)
  end

  def test_calculate_overall_priority_when_bad_average_rating
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(1, 5, 3, "This team has bad participation", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(1, 5, 5, "This team has bad participation", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    team_priority = team.calculate_overall_priority(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal(0, team_priority)
  end

  def test_find_priority_weighted_no_users 
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!     

    team_priority = team.find_priority_weighted(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_nil(team_priority)
  end
  
  def test_find_priority_weighted_no_feedback_with_users
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof
    team.save!

    team_priority = team.find_priority_weighted(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('High', team_priority)
  end

  def test_find_priority_weighted_when_all_users_submit_with_high_average_ratings
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2, user3]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(5, 5, 5, "I submitted", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(5, 5, 5, "I submitted", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    feedback3 = save_feedback(5, 5, 5, "I submitted", user3, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    team_priority = team.find_priority_weighted(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('Low', team_priority)
  end
  
  def test_find_priority_weighted_when_less_than_half_of_team_does_not_submit
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2, user3]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(5, 5, 5, "I submitted", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(5, 5, 5, "I submitted", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    team_priority = team.find_priority_weighted(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('Medium', team_priority)
  end
  
  def test_find_priority_weighted_when_okay_average_rating
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(3, 3, 3, "This team is okay", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(3, 3, 3, "This team is okay", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    team_priority = team.find_priority_weighted(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('Medium', team_priority)
  end

  def test_find_priority_weighted_when_more_than_half_of_team_does_not_submit
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(5, 5, 5, "I have a Low priority", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team)\

    team_priority = team.find_priority_weighted(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('High', team_priority)
  end

  def test_find_priority_weighted_when_one_member_submits_high_priority
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(1, 1, 1, "I have a High priority", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(5, 5, 5, "I have a Low priority", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    team_priority = team.find_priority_weighted(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('High', team_priority)
  end

  def test_find_priority_weighted_when_bad_average_rating
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(1, 5, 3, "This team has bad participation", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(1, 5, 5, "This team has bad participation", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    team_priority = team.find_priority_weighted(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('High', team_priority)
  end
  
  def test_find_students_not_submitted_no_submissions
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)

    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!   
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team2.users = [user3]
    team2.user = @prof 
    team2.save 

    # No submissions made yet 
    assert_equal([user1, user2], team.users_not_submitted([]))
  end 

  def test_find_students_not_submitted_partial_submissions
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!   

    feedback = save_feedback(2,3,4, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)

    assert_equal([user2], team.users_not_submitted([feedback]))
  end

  def test_find_students_not_submitted_all_submitted
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)

    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!   
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team2.users = [user3]
    team2.user = @prof 
    team2.save

    feedback = save_feedback(3,5,3, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    feedback2 = save_feedback(5,4,2, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team)
    assert_equal([], team.users_not_submitted([feedback, feedback2]))
  end

  def test_find_students_not_submitted_over_submitted 
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)

    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!   
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team2.users = [user3]
    team2.user = @prof 
    team2.save

    feedback = save_feedback(3,2,3, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    feedback2 = save_feedback(5,2,3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team)
    feedback3 = save_feedback(3,2,3, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 2), team)
    assert_equal([], team.users_not_submitted([feedback, feedback2, feedback3]))
  end 

  def test_find_students_not_submitted_user_not_in_team
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!    
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team2.users = [user3]
    team2.user = @prof 
    team2.save

    feedback = save_feedback(2,2,3, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    feedback2 = save_feedback(5,4,3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team)
    feedback3 = save_feedback(2,3,3, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 3, 2), team2)
    assert_equal([], team.users_not_submitted([feedback, feedback2, feedback3]))
  end

  def test_fraction_of_users_not_submitted_with_no_submissions_and_no_users
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = []
    team.user = @prof
    team.save!

    assert_equal(0, team.fraction_of_users_not_submitted([]))
  end

  def test_fraction_of_users_not_submitted_with_no_submissions_and_users
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof
    team.save!

    # 100% of team did not submit.
    assert_equal(1.0, team.fraction_of_users_not_submitted([]))
  end

  def test_fraction_of_users_not_submitted_less_than_half_of_team_submitted
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2, user3]
    team.user = @prof
    team.save!

    feedback = save_feedback(2, 2, 3, "I submitted!", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    assert_in_delta(0.6666, team.fraction_of_users_not_submitted([feedback]))
  end

  def test_fraction_of_users_not_submitted_more_than_half_of_team_submitted
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2, user3]
    team.user = @prof
    team.save!

    feedback1 = save_feedback(2, 2, 3, "I submitted!", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    feedback2 = save_feedback(2, 2, 3, "I submitted!", user2, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    assert_in_delta(0.3333, team.fraction_of_users_not_submitted([feedback1, feedback2]))
  end

  def test_fraction_of_users_not_submitted_all_of_team_submitted
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2, user3]
    team.user = @prof
    team.save!

    feedback1 = save_feedback(2, 2, 3, "I submitted!", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    feedback2 = save_feedback(2, 2, 3, "I submitted!", user2, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    feedback3 = save_feedback(2, 2, 3, "I submitted!", user3, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    assert_in_delta(0.0, team.fraction_of_users_not_submitted([feedback1, feedback2, feedback3]))
  end

  def test_find_current_feedback 
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback = save_feedback(4,3,2, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team)
    feedback2 = save_feedback(5,4,3, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team)
    feedback3 = save_feedback(4,4,3, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    result = team.current_feedback(d=Date.new(2021, 3, 2))
    assert_includes( result, feedback )
    assert_includes( result, feedback2 )
    refute_includes( result, feedback3 )
    assert_equal( 2, result.length )
  end
  
  def test_generate_team_code 
    assert_equal(6, Team::generate_team_code(length = 6).size)
  end
  
  def test_status_no_users 
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!     

    status = team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('blue', status)
  end
  
  def test_status_no_feedback_with_users
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof
    team.save!

    status = team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('red', status)
  end

  def test_status_when_all_users_submit_with_good_average_ratings
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2, user3]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(5, 5, 5, "I submitted", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(5, 5, 5, "I submitted", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    feedback3 = save_feedback(5, 5, 5, "I submitted", user3, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    status = team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('green', status)
  end
  
  def test_status_when_less_than_half_of_team_does_not_submit
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2, user3]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(5, 5, 5, "I submitted", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(5, 5, 5, "I submitted", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    status = team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('yellow', status)
  end
  
  def test_status_when_okay_average_rating
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(3, 3, 3, "This team is okay", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(3, 3, 3, "This team is okay", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    status = team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('yellow', status)
  end

  def test_status_when_more_than_half_of_team_does_not_submit
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(5, 5, 5, "I have a Low priority", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team)\

    status = team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('red', status)
  end

  def test_status_when_one_member_submits_high_priority
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(1, 1, 1, "I have a High priority", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(5, 5, 5, "I have a Low priority", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    status = team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('red', status)
  end

  def test_status_when_bad_average_rating
    user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback1 = save_feedback(1, 5, 3, "This team has bad participation", user1, DateTime.civil_from_format(:local, 2021, 3, 27), team)
    feedback2 = save_feedback(1, 5, 5, "This team has bad participation", user2, DateTime.civil_from_format(:local, 2021, 4, 2), team)
    
    status = team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3))
    assert_equal('red', status)
  end
end
