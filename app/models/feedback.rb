class Feedback < ApplicationRecord
  # When creating a Feedback object, the default priority is set to 2 = 'Low'.
  HIGH = 0.freeze
  NO_FEEDBACK = nil.freeze
  MEDIUM = 1.freeze
  LOW = 2.freeze
  PRIORITY_LEVEL = { HIGH => 'High', MEDIUM => 'Medium', LOW => 'Low' }.freeze
  PRIORITY_COLOURS = { HIGH => 'red', NO_FEEDBACK => 'blue', MEDIUM => 'yellow', LOW => 'green' }.freeze
  CHOICES = [1, 2, 3, 4, 5].freeze
  BAD_RATING = (Feedback::CHOICES.min + ((Feedback::CHOICES.max - Feedback::CHOICES.min)  / Feedback::PRIORITY_LEVEL.size.to_f)).freeze
  OKAY_RATING = ((2 * Feedback::BAD_RATING) - Feedback::CHOICES.min).freeze

  belongs_to :user
  belongs_to :team

  #requires feedback to have at minimal a rating score for each rating type, comments are optional 
  validates_presence_of :participation_rating, :effort_rating, :punctuality_rating
  #allows a max of 2048 characters for additional comments
  validates_length_of :comments, :maximum => 2048, :message => "Please limit your comment to 2048 characters or less!"

  # TODO: Implement test cases.
  scope :filter_by_first_name, -> (first_name) { joins(:user).where("UPPER(first_name) LIKE ?", "#{first_name.upcase}%") }
  scope :filter_by_last_name, -> (last_name) { joins(:user).where("UPPER(last_name) LIKE ?", "#{last_name.upcase}%") }
  scope :filter_by_team_name, -> (team_name) { joins(:team).where("team_name = ?", team_name) }
  scope :filter_by_participation_rating, -> (participation_rating) { where(participation_rating: participation_rating) }
  scope :filter_by_effort_rating, -> (effort_rating) { where(effort_rating: effort_rating) }
  scope :filter_by_punctuality_rating, -> (punctuality_rating) { where(punctuality_rating: punctuality_rating) }
  scope :filter_by_priority, -> (priority) { where(priority: priority) }
  scope :filter_by_timestamp, -> (start_date, end_date) { where(timestamp: start_date..end_date) }

  def format_time(given_date)
  #refomats the UTC time in terms if YYYY/MM?DD HH:MM
      #current_time = given_date.in_time_zone('Eastern Time (US & Canada)').strftime('%Y/%m/%d %H:%M')
      current_time = given_date.strftime('%Y/%m/%d %H:%M')
      return current_time
  end

  # TODO: Implement test cases.
  def self.sort(column, direction)
    self.left_joins(:user, :team).order("#{column} #{direction}")
  end

  # Calculates the priority for this feedback by using the participation, effort, and punctuality ratings.
  def calculate_priority
    ratings = [self.participation_rating, self.effort_rating, self.punctuality_rating]
    
    if ratings.any?{ |rating| rating.nil? } or ratings.any?{ |rating| rating <= Feedback::BAD_RATING }
      return Feedback::HIGH
    elsif ratings.any?{ |rating| rating <= Feedback::OKAY_RATING }
      return Feedback::MEDIUM
    else
      return Feedback::LOW
    end
  end

  def get_priority_word
    return Feedback::PRIORITY_LEVEL[self.priority]
  end

  # Determines if feedback is part of the current duration.
  def is_from_this_week?
    today = DateTime.now
    week_range = self.team.week_range(today.cwyear, today.cweek)
    return self.timestamp.between?(week_range[:start_date], week_range[:end_date]) 
  end

  def status()
    priority = self.priority
    return Feedback::PRIORITY_COLOURS[priority]
  end

end
