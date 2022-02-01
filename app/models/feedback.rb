class Feedback < ApplicationRecord
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
  
  # takes list of feedbacks and returns average rating
  def self.average_participation_rating(feedbacks)
    (feedbacks.sum{|feedback| feedback.participation_rating}.to_f/feedbacks.count.to_f).round(2)
  end

  def self.average_effort_rating(feedbacks)
    (feedbacks.sum{|feedback| feedback.effort_rating}.to_f/feedbacks.count.to_f).round(2)
  end

  def self.average_punctuality_rating(feedbacks)
    (feedbacks.sum{|feedback| feedback.punctuality_rating}.to_f/feedbacks.count.to_f).round(2)
  end
end
