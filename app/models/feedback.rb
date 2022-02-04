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
  OKAY_RATING = (2 * Feedback::BAD_RATING).freeze

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
    participation = self.participation_rating
    effort = self.effort_rating
    punctuality = self.punctuality_rating

    # Compares ratings values to specified rating being a Boolean.
    bad = Feedback::BAD_RATING
    okay = Feedback::OKAY_RATING
    any_rating_is_bad = participation <= bad or effort <= bad or punctuality <= bad
    any_rating_is_okay = participation <= okay or effort <= okay or punctuality <= okay

    if any_rating_is_bad
      return Feedback::HIGH
    elsif any_rating_is_okay
      return Feedback::MEDIUM
    else
      return Feedback::LOW
    end
  end

  def get_priority_word
    return Feedback::PRIORITY_LEVEL[self.priority]
  end
end
