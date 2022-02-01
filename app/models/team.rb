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
      students.push(student.name)
    end 
    return students
  end
  
  def find_priority_weighted(start_date, end_date)
    #if AT LEAST ONE of the feedbacks have a priority score of 0, meaning "urgent", the professor will see a status of "Urgent" for the respective team
    #if at least 1/3 of the feedbacks submitted have a priority score of 1, meaning "medium", the professor will see a status of "Urgent" for the respective team, used float division
    #every other case is considered a priority of low since it was the default score submitted per feedback
    #array index 0 represents number of "urgent" priorities that a team has, index 1 represents number of "medium" priorities, index 2 represents number of "low" priorities
    priority_holder = Array.new(3)
    #gets all feedbacks for a given week
    feedbacks = self.feedbacks.where(:timestamp => start_date..end_date)
    
    if feedbacks.count == 0
      return nil
    end
    
    priority_holder.each_with_index {|val, index| priority_holder[index] = feedbacks.where(priority: index).count}

    if priority_holder[0] > 0
      return "High" 
    elsif priority_holder[1] >= feedbacks.count/3.0
      return "Medium" 
    else
      return "Low"
    end 
  end 
  
  #gets the average team rating for the professor's team summary view
  def self.feedback_average_participation_rating(feedbacks)
    if feedbacks.count > 0
      (feedbacks.sum{|feedback| feedback.participation_rating}.to_f/feedbacks.count.to_f).round(2)
    else
      return nil
    end
  end
  
  def self.feedback_average_effort_rating(feedbacks)
    if feedbacks.count > 0
      (feedbacks.sum{|feedback| feedback.effort_rating}.to_f/feedbacks.count.to_f).round(2)
    else
      return nil
    end
  end

  def self.feedback_average_punctuality_rating(feedbacks)
    if feedbacks.count > 0
      (feedbacks.sum{|feedback| feedback.punctuality_rating}.to_f/feedbacks.count.to_f).round(2)
    else
      return nil
    end
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
    submitted = Array.new
    feedbacks.each do |feedback|
      submitted << feedback.user
    end
    
    self.users.to_ary - submitted
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
    priority = self.find_priority_weighted(start_date, end_date)
    feedbacks = self.feedbacks.where(:timestamp => start_date..end_date)
    participation_rating = Team::feedback_average_participation_rating(feedbacks)
    participation_rating = participation_rating.nil? ? 10 : participation_rating
    effort_rating = Team::feedback_average_effort_rating(feedbacks)
    effort_rating = effort_rating.nil? ? 10 : effort_rating
    punctuality_rating = Team::feedback_average_punctuality_rating(feedbacks)
    punctuality_rating = punctuality_rating.nil? ? 10 : punctuality_rating
    users_not_submitted = self.users_not_submitted(feedbacks)
    users_not_submitted = self.users.to_ary.size == 0 ? 0 : users_not_submitted.size.to_f / self.users.to_ary.size
    
    if priority == 'High' or participation_rating <= 5 or effort_rating <= 5 or punctuality_rating <= 5
      return 'red'
    elsif priority == 'Medium' or participation_rating <= 7 or effort_rating <= 7 or punctuality_rating <= 7 or users_not_submitted >= 0.5
      return 'yellow'
    else 
      return 'green'
    end  
  end
  
  def self.generate_team_code(length = 6)
    team_code = rand(36**length).to_s(36).upcase
    
    while team_code.length != length or (Team.exists?(:team_code=>team_code) or Option.exists?(:admin_code=>team_code))
      team_code = rand(36**length).to_s(36).upcase
    end
    
    return team_code.upcase
  end
end
