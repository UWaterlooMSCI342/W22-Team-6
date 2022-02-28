require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  #parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  def login(email, password)
    assert_current_path login_url
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_on "Login"
  end 
  
  def save_feedback(participation_rating, effort_rating, punctuality_rating, comments, user, timestamp, team)
    feedback = Feedback.new(participation_rating: participation_rating, effort_rating: effort_rating, punctuality_rating: punctuality_rating, comments: comments)
    feedback.user = user
    feedback.priority = feedback.calculate_priority
    feedback.timestamp = feedback.format_time(timestamp)
    feedback.team = team
    feedback.save
    feedback
  end

  # Helper function creating many feedbacks to test functionalties that require a group of feedbacks.
  def create_many_feedbacks
    user1 = User.new(email: "user1@user1.com", first_name: "User1", last_name: "User1", password: "password", password_confirmation: "password", is_admin: false)
    user2 = User.new(email: "user2@user2.com", first_name: "User2", last_name: "User2", password: "password", password_confirmation: "password", is_admin: false)
    user3 = User.new(email: "user3@user3.com", first_name: "User3", last_name: "User3", password: "password", password_confirmation: "password", is_admin: false)

    team1 = Team.create(team_name: "Team1", team_code: "TEAM01", user: @prof)
    team1.users = [user1, user2]
    team2 = Team.create(team_name: "Team2", team_code: "TEAM02", user: @prof)
    team2.users = [user3]

    user1.save!
    user2.save!
    user3.save!

    week1 = DateTime.civil_from_format(:local, 2022, 1, 20)
    week2 = week1 + 7
    week3 = week1 + 14

    # Variable format is `user_feedback_week` (e.g. `u1_fb_w1`).
    @u1_fb_w1 = save_feedback(5, 5, 5, "First week went great!", user1, week1, team1)
    @u1_fb_w2 = save_feedback(3, 3, 3, "Second week was okay!", user1, week2, team1)
    @u1_fb_w3 = save_feedback(1, 1, 1, "Third week was terrible!", user1, week3, team1)

    @u2_fb_w1 = save_feedback(4, 4, 4, "First week was decent!", user2, week1, team1)
    # User2 did not submit feedback for week2.
    @u2_fb_w3 = save_feedback(4, 4, 4, "Third week was decent!", user2, week3, team1)

    # User3 did not submit feedback for week1.
    @u3_fb_w2 = save_feedback(1, 1, 1, "I don't like my team!", user3, week2, team2)
    @u3_fb_w3 = save_feedback(1, 1, 1, "I don't like my team!", user3, week3, team2)

    @default_feedbacks = [@u1_fb_w1, @u1_fb_w2, @u1_fb_w3, @u2_fb_w1, @u2_fb_w3, @u3_fb_w2, @u3_fb_w3]

    return Feedback.all
  end
end
