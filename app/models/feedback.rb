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

  def format_time(given_date)
  #refomats the UTC time in terms if YYYY/MM?DD HH:MM
      #current_time = given_date.in_time_zone('Eastern Time (US & Canada)').strftime('%Y/%m/%d %H:%M')
      current_time = given_date.strftime('%Y/%m/%d %H:%M')
      return current_time
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
end
