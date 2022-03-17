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
  # FILTERABLE_PARAMS = [:first_name, :last_name, :team_name, :participation_rating, :effort_rating, :punctuality_rating, :priority].freeze
  FILTERABLE_PARAMS = [:first_name, :last_name, :team_name, :priority]
  MULTI_OPTION_FILTERABLE_PARAMS = [:participation_rating, :effort_rating, :punctuality_rating]
  FILTERABLE_PARAMS_STRINGS = ["First Name", "Last Name", "Team"].freeze
  MULTI_OPTION_FILTERABLE_PARAMS_STRINGS = ["Participation Rating", "Effort Rating", "Punctuality Rating"]

  belongs_to :user
  belongs_to :team

  #requires feedback to have at minimal a rating score for each rating type, comments are optional 
  validates_presence_of :participation_rating, :effort_rating, :punctuality_rating
  #allows a max of 2048 characters for additional comments
  validates_length_of :comments, :maximum => 2048, :message => "Please limit your comment to 2048 characters or less!"

  scope :filter_by_first_name, -> (first_name) { left_joins(:user).where("UPPER(first_name) LIKE ?", "#{first_name.upcase}%") }
  scope :filter_by_last_name, -> (last_name) { left_joins(:user).where("UPPER(last_name) LIKE ?", "#{last_name.upcase}%") }
  scope :filter_by_team_name, -> (team_name) { left_joins(:team).where("team_name = ?", team_name) }
  
  #scope :filter_by_participation_rating, -> (participation_rating) { where(participation_rating: participation_rating) }
  # scope :filter_by_participation_rating, -> (participation_rating) { where("participation_rating BETWEEN ? AND ?", "#{participation_rating.first}", "#{participation_rating.last}") }
  scope :filter_by_participation_rating, -> (participation_rating_start, participation_rating_end) { where("participation_rating BETWEEN ? AND ?", "#{participation_rating_start}", "#{participation_rating_end}") }
  #scope :filter_by_effort_rating, -> (effort_rating) { where(effort_rating: effort_rating) }
  scope :filter_by_effort_rating, -> (effort_rating_start, effort_rating_end) { where("effort_rating BETWEEN ? AND ?", "#{effort_rating_start}", "#{effort_rating_end}") }
  #scope :filter_by_punctuality_rating, -> (punctuality_rating) { where(punctuality_rating: punctuality_rating) }
  # scope :filter_by_punctuality_rating, -> (punctuality_rating) { where("punctuality_rating BETWEEN ? AND ?", "#{punctuality_rating.first}", "#{punctuality_rating.last}") }
  scope :filter_by_punctuality_rating, -> (punctuality_rating_start, punctuality_rating_end) { where("punctuality_rating BETWEEN ? AND ?", "#{punctuality_rating_start}", "#{punctuality_rating_end}") }

  scope :filter_by_priority, -> (priority) { where(priority: priority) }
  scope :filter_by_timestamp, -> (start_date, end_date) { where(timestamp: self.string_date_to_EST(start_date).beginning_of_day..self.string_date_to_EST(end_date).end_of_day) }

  def format_time(given_date)
  #refomats the UTC time in terms if YYYY/MM?DD HH:MM
      #current_time = given_date.in_time_zone('Eastern Time (US & Canada)').strftime('%Y/%m/%d %H:%M')
      current_time = given_date.strftime('%Y/%m/%d %H:%M')
      return current_time
  end

  def self.sort_data(column, direction)
    return self.left_joins(:user, :team).order("#{column} #{direction}")
  end

  def self.filter_data(params)
    # filtering_params = params.slice(*Feedback::FILTERABLE_PARAMS)
    single_option_filtering_params = params.slice(*Feedback::FILTERABLE_PARAMS)
    multi_option_filtering_params = params.slice(*Feedback::MULTI_OPTION_FILTERABLE_PARAMS)

    feedbacks = self.all

    single_option_filtering_params.each do |key, value|
        feedbacks = feedbacks.public_send("filter_by_#{key}", value) if !value.empty?
    end

    # multi_option_filtering_params.each do |key, value1, value2|
    #     feedbacks = feedbacks.public_send("filter_by_#{key}", value1, value2) if !value1.empty? AND !value2.empty?
    # end

    feedbacks = feedbacks.filter_by_participation_rating(params[:participation_rating_start], params[:participation_rating_end]) if (params[:participation_rating_start].present? and params[:participation_rating_end].present?)
    feedbacks = feedbacks.filter_by_effort_rating(params[:effort_rating_start], params[:effort_rating_end]) if (params[:effort_rating_start].present? and params[:effort_rating_end].present?)
    feedbacks = feedbacks.filter_by_punctuality_rating(params[:punctuality_rating_start], params[:punctuality_rating_end]) if (params[:punctuality_rating_start].present? and params[:punctuality_rating_end].present?)
    
    feedbacks = feedbacks.filter_by_timestamp(params[:start_date], params[:end_date]) if (params[:start_date].present? and params[:end_date].present?)
    return feedbacks
  end

  def self.choices # checkboxes in filter form require a hash
    choices_hash = {}
    CHOICES.each do |c|
      choices_hash[c] = c.to_s
    end
    return choices_hash
  end

  def self.filter_and_sort(params, column, direction)
    return self.filter_data(params).sort_data(column, direction)
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

  def display_timestamp
    return self.timestamp.strftime('%Y-%m-%d %H:%M EST')
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


  private

  # Converts a String date (e.g. "2022-02-20") to the same time Date in EST.
  def self.string_date_to_EST(str_date)
    # Since a String date starts in UTC time, when turing this date to EST, the date is no longer accurate.
    # Hence, 5h are added back to still have same date of "2022-02-20", but in correct EST time.
    return str_date.to_datetime.in_time_zone("EST") + 5.hours
  end
end
