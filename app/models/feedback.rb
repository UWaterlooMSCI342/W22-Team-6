class Feedback < ApplicationRecord
  belongs_to :user
  belongs_to :team

  #requires feedback to have at minimal a rating score, comments are optional 
  validates_presence_of :rating
  #allows a max of 2048 characters for additional comments
  validates_length_of :comments, :maximum => 2048, :message => "Please limit your comment to 2048 characters or less!"

  def format_time(given_date)
  #refomats the UTC time in terms if YYYY/MM?DD HH:MM
      #current_time = given_date.in_time_zone('Eastern Time (US & Canada)').strftime('%Y/%m/%d %H:%M')
      current_time = given_date.strftime('%Y/%m/%d %H:%M')
      return current_time
  end
  
  # takes list of feedbacks and returns average rating
  def self.average_rating(feedbacks)
    (feedbacks.sum{|feedback| feedback.rating}.to_f/feedbacks.count.to_f).round(2)
  end
end
