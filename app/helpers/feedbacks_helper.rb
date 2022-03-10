module FeedbacksHelper
  # returns start and end date of a given week and year in a hash
  def week_range(cyear, cweek)
    start_date = Date.commercial(cyear, cweek)
    end_date = start_date.next_day(6)

    start_date = Time.zone.local(start_date.year, start_date.month, start_date.day)
    end_date = Time.zone.local(end_date.year, end_date.month, end_date.day)
    
    {start_date: start_date.to_datetime.beginning_of_day, 
     end_date: end_date.to_datetime.end_of_day}
  end  
  
  def days_till_end(date=now, cweek=now.cweek, cwyear=now.cwyear)
    week_range = week_range(cwyear, cweek)
    (week_range[:end_date] - date).to_i
  end
  
  def now
    DateTime.current()
    # Time.zone.now.to_datetime 
  end
end
