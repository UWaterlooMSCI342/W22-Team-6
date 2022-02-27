class Team < ApplicationRecord   
  validates_length_of :team_name, maximum: 40
  validates_length_of :team_code, maximum: 26
  validates_uniqueness_of :team_code, :case_sensitive => false
  validate :code_unique
  validates_presence_of :team_name
  validates_presence_of :team_code
    
  belongs_to :user
  has_and_belongs_to_many :users
  has_many :feedbacks
  
  include FeedbacksHelper
  
  def code_unique 
    if Option.exists?(admin_code: self.team_code)
      errors.add(:team_code, 'not unique')
    end
  end
  
  def student_names 
    students = Array.new
    for student in self.users.to_ary
      students.push(student.full_name)
    end 
    return students
  end

  # Returns the number version of the priority level (e.g. 0).
  def calculate_overall_priority(start_date, end_date)
    # nil = 'No feedback' = 'blue':
    #   - If no users on team and no feedback.

    # 0 = 'High':
    #   - If more than 1/2 of team did not submit.
    #   - If at least one member has an individual priority of 'High'.
    #   - If any of the average ratings are on the lower end of the scale.

    # 1 = 'Medium':
    #   - If less than 1/2 of team did not submit, but at least 1 member still hasn't submitted.
    #   - If any of the average ratings are in the middle of the scale.

    # 2 = 'Low':
    #   - Any other case.

    # Gets all feedbacks for a given week.
    feedbacks = self.feedbacks.where(:timestamp => start_date..end_date)
    
    if feedbacks.empty? and self.users.empty?
      return Feedback::NO_FEEDBACK
    elsif feedbacks.empty?
      return Feedback::HIGH
    end

    # Calculate the team's average rating for each of the categories.
    avg_participation = Team.average_participation_rating(feedbacks)
    avg_effort = Team.average_effort_rating(feedbacks)
    avg_punctuality = Team.average_punctuality_rating(feedbacks)
    avg_ratings = [avg_participation, avg_effort, avg_punctuality]
    
    # Boolean variable confirming if at least one member individually submitted 'High' priority.
    is_any_feedback_high_priority = feedbacks.where(:priority => Feedback::HIGH).count > 0

    # Boolean variables determining what interval the rating categories falls under.
    any_rating_is_bad = avg_ratings.any?{ |rating| rating <= Feedback::BAD_RATING }
    any_rating_is_okay = avg_ratings.any?{ |rating| rating <= Feedback::OKAY_RATING }

    # Boolean variable checking the fraction of users who haven't submitted yet.
    fraction_of_users_not_submitted = self.fraction_of_users_not_submitted(feedbacks)
    half_of_team = 0.5
    more_than_half_not_submitted = fraction_of_users_not_submitted >= half_of_team
    less_than_half_not_submitted = fraction_of_users_not_submitted > 0

    if is_any_feedback_high_priority or any_rating_is_bad or more_than_half_not_submitted
      return Feedback::HIGH
    elsif less_than_half_not_submitted or any_rating_is_okay
      return Feedback::MEDIUM
    else 
      return Feedback::LOW
    end  
  end 

  # Returns the word version of the priority level (e.g. 'High').
  def find_priority_weighted(start_date, end_date)
    return Feedback::PRIORITY_LEVEL[calculate_overall_priority(start_date, end_date)]
  end 
  
  def self.average_participation_rating(feedbacks)
    return Team.calculate_average_rating(feedbacks, :participation_rating)
  end
  
  def self.average_effort_rating(feedbacks)    
    return Team.calculate_average_rating(feedbacks, :effort_rating)
  end

  def self.average_punctuality_rating(feedbacks)
    return Team.calculate_average_rating(feedbacks, :punctuality_rating)
  end
  
  # return a multidimensional array that is sorted by time (most recent first)
  # first element of each row is year and week, second element is the list of feedback
  def feedback_by_period
    periods = {}
    feedbacks = self.feedbacks
    if feedbacks.count > 0
      feedbacks.each do |feedback| 
        week = feedback.timestamp.to_date.cweek 
        year = feedback.timestamp.to_date.cwyear
        if periods.empty? || !periods.has_key?({year: year, week: week})
          periods[{year: year, week: week}] = [feedback]
        else 
          periods[{year: year, week: week}] << feedback
        end
      end
      periods.sort_by do |key, value| 
        [-key[:year], -key[:week]]
      end
    else
      nil
    end
  end
  
  def users_not_submitted(feedbacks)
    submitted_users = feedbacks.map{ |feedback| feedback.user }
    return self.users - submitted_users
  end

  def fraction_of_users_not_submitted(feedbacks)
    users_on_team = self.users.size.to_f
    no_users = 0
    if users_on_team == no_users
      return no_users
    end

    return self.users_not_submitted(feedbacks).size / users_on_team
  end
  
  def current_feedback(d=now)
    current_feedback = Array.new
    self.feedbacks.each do |feedback| 
      time = feedback.timestamp.to_datetime
      if time.cweek == d.cweek && time.cwyear == d.cwyear
        current_feedback << feedback 
      end 
    end 
    current_feedback
  end 
  
  def status(start_date, end_date)
    priority = self.calculate_overall_priority(start_date, end_date)
    return Feedback::PRIORITY_COLOURS[priority]
  end
  
  def self.generate_team_code(length = 6)
    team_code = rand(36**length).to_s(36).upcase
    
    while team_code.length != length or (Team.exists?(:team_code=>team_code) or Option.exists?(:admin_code=>team_code))
      team_code = rand(36**length).to_s(36).upcase
    end
    
    return team_code.upcase
  end


  private

  def self.calculate_average_rating(ratings, type_of_rating)
    if ratings.count == 0
      return nil
    end
    return (ratings.sum{ |rating| rating[type_of_rating] } / ratings.count.to_f).round(2)
  end
end
