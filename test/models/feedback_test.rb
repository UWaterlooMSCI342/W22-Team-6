require 'test_helper'
require 'date'
class FeedbackTest < ActiveSupport::TestCase
  setup do
    @user = User.new(email: 'xyz@gmail.com', password: '123456789', password_confirmation: '123456789',first_name: 'Elon', last_name: 'Musk', is_admin: false)
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    
    @team = Team.create(team_name: 'Test Team 1', team_code: 'TEAM_A', user: @prof)
    @user.teams << @team
    @user.save
  end
  
  test 'valid feedback' do
    #feedback with rating and comment and priority
    feedback = Feedback.new(participation_rating: 1, effort_rating: 4, punctuality_rating: 2, comments: "BB EOY 30", priority: 2)
    feedback.timestamp = feedback.format_time(DateTime.now)
    feedback.user = @user
    feedback.team = @user.teams.first
    feedback.save
    assert feedback.valid?
    
    #feedback with no optional comment
    feedback2 = Feedback.new(participation_rating: 1, effort_rating: 4, punctuality_rating: 2, priority: 2)
    feedback2.timestamp = feedback2.format_time(DateTime.now)
    feedback2.user = @user
    feedback2.team = @user.teams.first
    feedback2.save
    assert feedback2.valid?
  end
    
  test 'valid feedback default priority rating' do
    #student does not select a priority, default value 'low' is automatically selected
    feedback = Feedback.new(participation_rating: 1, effort_rating: 4, punctuality_rating: 2, comments: "terrible!")
    feedback.timestamp = feedback.format_time(DateTime.now)
    feedback.user = @user
    feedback.team = @user.teams.first
    feedback.save
    assert feedback.valid?
  end
  
  test 'invalid feedback comment over 2048 characters' do
    #test with 2050 characters 
    feedback = Feedback.new(participation_rating: 1, effort_rating: 4, punctuality_rating: 2, priority: 2, comments: "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")
    feedback.timestamp = feedback.format_time(DateTime.now)
    feedback.user = @user
    feedback.team = @user.teams.first
    feedback.save
    refute feedback.valid?, 'Please limit your comment to 2048 characters or less!'
    assert_not_nil feedback.errors[:comments]
  end 
  
  test 'valid feedback comment with 2048 characters' do
    #test with 2048 characters 
    feedback = Feedback.new(participation_rating: 1, effort_rating: 4, punctuality_rating: 2, priority: 2, comments: "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")
    feedback.timestamp = feedback.format_time(DateTime.now)
    feedback.user = @user
    feedback.team = @user.teams.first
    feedback.save
    assert feedback.valid?
  end 
  
  test 'invalid feedback no rating provided' do 
    #when students do not submit a rating 
    feedback = Feedback.new(participation_rating: nil, effort_rating: nil, punctuality_rating: nil, priority: 2, comments: "no rating provided")
    feedback.timestamp = feedback.format_time(DateTime.now)
    feedback.user = @user
    feedback.team = @user.teams.first
    feedback.save
    refute feedback.valid?, "Rating can't be blank"
    assert_not_nil feedback.errors[:rating]
  end

  def test_filter_by_first_name_case_insensitive
    feedbacks = create_many_feedbacks
    expected = [@u1_fb_w1, @u1_fb_w2, @u1_fb_w3]
    assert_equal(expected, feedbacks.filter_by_first_name("USER1"))
  end

  def test_filter_by_first_name_unfinished_beginning
    feedbacks = create_many_feedbacks
    assert_equal([], feedbacks.filter_by_first_name("ser1"))
  end

  def test_filter_by_first_name_unfinished_ending
    feedbacks = create_many_feedbacks
    assert_equal(@default_feedbacks, feedbacks.filter_by_first_name("Us"))
  end

  def test_filter_by_first_name_word_not_found
    feedbacks = create_many_feedbacks
    assert_equal([], feedbacks.filter_by_first_name("Student"))
  end

  def test_filter_by_last_name_case_insensitive
    feedbacks = create_many_feedbacks
    expected = [@u1_fb_w1, @u1_fb_w2, @u1_fb_w3]
    assert_equal(expected, feedbacks.filter_by_last_name("USER1"))
  end

  def test_filter_by_last_name_unfinished_beginning
    feedbacks = create_many_feedbacks
    assert_equal([], feedbacks.filter_by_last_name("ser1"))
  end

  def test_filter_by_last_name_unfinished_ending
    feedbacks = create_many_feedbacks
    assert_equal(@default_feedbacks, feedbacks.filter_by_last_name("Us"))
  end

  def test_filter_by_last_name_word_not_found
    feedbacks = create_many_feedbacks
    assert_equal([], feedbacks.filter_by_last_name("Student"))
  end

  def test_filter_by_team_name_case_sensitive
    feedbacks = create_many_feedbacks
    assert_equal([], feedbacks.filter_by_team_name("TEAM2"))
    assert_equal([@u3_fb_w2, @u3_fb_w3], feedbacks.filter_by_team_name("Team2"))
  end

  def test_filter_by_team_name_unfinished_word
    feedbacks = create_many_feedbacks
    assert_equal([], feedbacks.filter_by_team_name("Tea"))
  end

  def test_filter_by_participation_rating_value_not_found
    feedbacks = create_many_feedbacks
    assert_equal([], feedbacks.filter_by_participation_rating(7))
  end

  def test_filter_by_participation_rating_value_found
    feedbacks = create_many_feedbacks
    expected = [@u1_fb_w3, @u3_fb_w2, @u3_fb_w3]
    assert_equal(expected, feedbacks.filter_by_participation_rating(1))
  end

  def test_filter_by_effort_rating_value_not_found
    feedbacks = create_many_feedbacks
    assert_equal([], feedbacks.filter_by_effort_rating(7))
  end

  def test_filter_by_effort_rating_value_found
    feedbacks = create_many_feedbacks
    expected = [@u1_fb_w3, @u3_fb_w2, @u3_fb_w3]
    assert_equal(expected, feedbacks.filter_by_effort_rating(1))
  end

  def test_filter_by_punctuality_rating_value_not_found
    feedbacks = create_many_feedbacks
    assert_equal([], feedbacks.filter_by_punctuality_rating(7))
  end

  def test_filter_by_punctuality_rating_value_found
    feedbacks = create_many_feedbacks
    expected = [@u1_fb_w3, @u3_fb_w2, @u3_fb_w3]
    assert_equal(expected, feedbacks.filter_by_punctuality_rating(1))
  end

  def test_filter_by_priority_value_not_found
    feedbacks = create_many_feedbacks
    assert_equal([], feedbacks.filter_by_priority(7))
  end

  def test_filter_by_priority_value_found
    feedbacks = create_many_feedbacks
    expected = [@u1_fb_w3, @u3_fb_w2, @u3_fb_w3]
    high_priority = 0
    assert_equal(expected, feedbacks.filter_by_priority(high_priority))
  end

  def test_filter_by_timestamp_dates_out_of_range
    feedbacks = create_many_feedbacks
    start_date = DateTime.now
    end_date = start_date + 6
    assert_equal([], feedbacks.filter_by_timestamp(start_date, end_date))
  end

  def test_filter_by_timestamp_some_dates_in_range
    feedbacks = create_many_feedbacks
    start_date = DateTime.civil_from_format(:local, 2022, 1, 20)
    end_date = start_date + 6
    assert_equal([@u1_fb_w1, @u2_fb_w1], feedbacks.filter_by_timestamp(start_date, end_date))
  end

  def test_sort_data_valid_feedbacks_column
    feedbacks = create_many_feedbacks
    expected = [@u1_fb_w1, @u2_fb_w1, @u2_fb_w3, @u1_fb_w2, @u3_fb_w3, @u3_fb_w2, @u1_fb_w3]
    assert_equal(expected, feedbacks.sort_data("effort_rating", "DESC"))
  end

  def test_sort_data_valid_users_column
    feedbacks = create_many_feedbacks
    assert_equal(@default_feedbacks, feedbacks.sort_data("first_name", "ASC"))
  end

  def test_sort_data_valid_teams_column
    feedbacks = create_many_feedbacks
    expected = [@u2_fb_w3, @u2_fb_w1, @u1_fb_w3, @u1_fb_w2, @u1_fb_w1, @u3_fb_w3, @u3_fb_w2]
    assert_equal(expected, feedbacks.sort_data("team_name", "ASC"))
  end

  def test_sort_data_invalid_direction
    feedbacks = create_many_feedbacks
    error = assert_raise(Exception) { feedbacks.sort_data("priority", "LEFT") }
    assert_equal( 'Query method called with non-attribute argument(s): "priority LEFT"', error.message )
  end

  def test_filter_data_all_valid_params
    feedbacks = create_many_feedbacks
    params = { first_name: "User1", last_name: "User1", team_name: "Team1", participation_rating: 5, effort_rating: 5, punctuality_rating: 5, priority: 2, start_date: DateTime.civil_from_format(:local, 2022, 1, 18), end_date: DateTime.civil_from_format(:local, 2022, 1, 22) }
    assert_equal([@u1_fb_w1], feedbacks.filter_data(params))
  end

  def test_filter_data_some_valid_some_invalid_params
    feedbacks = create_many_feedbacks
    params = { effort_rating: 5, first_name: "Us", invalid: 4, bad: "Bad" }
    assert_equal([@u1_fb_w1], feedbacks.filter_data(params))
  end

  def test_filter_data_no_valid_params
    feedbacks = create_many_feedbacks
    params = { invalid: 4, bad: "Bad" }
    assert_equal(@default_feedbacks, feedbacks.filter_data(params))
  end

  def test_filter_data_no_params
    feedbacks = create_many_feedbacks
    assert_equal(@default_feedbacks, feedbacks.filter_data({}))
  end

  def test_filter_data_start_date_not_provided
    feedbacks = create_many_feedbacks
    params = { end_date: DateTime.civil_from_format(:local, 2022, 1, 22) }
    assert_equal(@default_feedbacks, feedbacks.filter_data(params))
  end

  def test_filter_data_end_date_not_provided
    feedbacks = create_many_feedbacks
    params = { start_date: DateTime.civil_from_format(:local, 2022, 1, 22) }
    assert_equal(@default_feedbacks, feedbacks.filter_data(params))
  end

  def test_filter_data_dates_outside_timestamps
    feedbacks = create_many_feedbacks
    params = { start_date: DateTime.civil_from_format(:local, 2022, 1, 10), end_date: DateTime.civil_from_format(:local, 2022, 1, 15) }
    assert_equal([], feedbacks.filter_data(params))
  end

  def test_filter_and_sort_valid_params
    feedbacks = create_many_feedbacks
    params = { participation_rating: 1, effort_rating: 1, punctuality_rating: 1 }
    expected = [@u3_fb_w2, @u3_fb_w3, @u1_fb_w3]
    assert_equal(expected, feedbacks.filter_and_sort(params, "team_name", "DESC"))
  end

  def test_filter_and_sort_only_filtering
    feedbacks = create_many_feedbacks
    params = { participation_rating: 1, effort_rating: 1, punctuality_rating: 1 }
    expected = [@u1_fb_w3, @u3_fb_w2, @u3_fb_w3]
    assert_equal(expected, feedbacks.filter_and_sort(params, "first_name", "ASC"))
  end

  def test_filter_and_sort_only_sorting
    feedbacks = create_many_feedbacks
    assert_equal(@default_feedbacks, feedbacks.filter_and_sort({}, "first_name", "ASC"))
  end

  def test_calculate_priority_high
    feedback = Feedback.create(participation_rating: 1, effort_rating: 1, punctuality_rating: 1, comments: "Bad rating", user: @user, timestamp: DateTime.now, team: @team)
    assert_equal(0, feedback.calculate_priority)
  end

  def test_calculate_priority_medium
    feedback = Feedback.create(participation_rating: 3, effort_rating: 3, punctuality_rating: 3, comments: "Okay rating", user: @user, timestamp: DateTime.now, team: @team)
    assert_equal(1, feedback.calculate_priority)
  end

  def test_calculate_priority_low
    feedback = Feedback.create(participation_rating: 5, effort_rating: 5, punctuality_rating: 5, comments: "Good rating", user: @user, timestamp: DateTime.now, team: @team)
    assert_equal(2, feedback.calculate_priority)
  end

  def test_get_priority_word_high
    feedback = save_feedback(1, 1, 1, "Bad rating", @user, DateTime.now, @team)
    assert_equal('High', feedback.get_priority_word)
  end

  def test_get_priority_word_medium
    feedback = save_feedback(3, 3, 3, "Okay rating", @user, DateTime.now, @team)
    assert_equal('Medium', feedback.get_priority_word)
  end

  def test_get_priority_word_low
    feedback = save_feedback(5, 5, 5, "Good rating", @user, DateTime.now, @team)
    assert_equal('Low', feedback.get_priority_word)
  end

  def test_display_timestamp
    feedback = save_feedback(5, 5, 5, "Good rating", @user, DateTime.new(2022, 2, 20, 4, 37, 6), @team)
    assert_equal('2022-02-20 04:37 EST', feedback.display_timestamp)
  end

  def test_is_from_this_week_before_week
    feedback = save_feedback(5, 5, 5, "Before Week", @user, DateTime.civil_from_format(:local, 2022, 1, 20), @team)
    assert_equal(false, feedback.is_from_this_week?)
  end

  def test_is_from_this_week_during_week
    feedback = save_feedback(5, 5, 5, "During Week", @user, DateTime.now, @team)
    assert_equal(true, feedback.is_from_this_week?)
  end
end
