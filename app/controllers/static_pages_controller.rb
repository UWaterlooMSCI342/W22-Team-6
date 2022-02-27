require 'csv'

class StaticPagesController < ApplicationController

  before_action :get_teams, :current_week
  helper_method :rating_reminders, :has_submitted
  helper_method :days_till_end_week

  
  def home
    unless logged_in?
      redirect_to login_path
    else
      @user = current_user
      @rating_reminders = @user.rating_reminders
      @has_submitted = @user.has_submitted
      @days_till_end_week = days_till_end(@now, @cweek, @cwyear)
      render :home
    end
  end
  
  def help
    unless logged_in?
      redirect_to login_path
    else
       if current_user.is_admin
         render :help
       else
         redirect_to root_url
       end
    end
  end

  def download
    teams = Team.all
    @missing = {}
    @start_date = @week_range[:start_date] - 7.days
    @end_date = @week_range[:end_date] - 7.days
    
    teams.each do |team| 
      # @unsubmitted[:current_week][team.id] = team.users_not_submitted(team.current_feedback).map{|user| user.name}
      @missing[team.id] = team.users_not_submitted(team.current_feedback(now - 7.days))
      
    end

    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=download.csv"
      end 
    end 
  end 

  def get_teams
    @teams = Team.all
    @unsubmitted = {current_week: {}, previous_week: {}}
    @teams.each do |team| 
      @unsubmitted[:current_week][team.id] = team.users_not_submitted(team.current_feedback).map{|user| user.full_name }
      @unsubmitted[:previous_week][team.id] = team.users_not_submitted(team.current_feedback(now - 7.days)).map{|user| user.full_name}
    end
  end 
  
  def show_reset_password 
  end
  
  def reset_password
    unless logged_in?
      redirect_to login_path 
    else 
      @user = current_user 
      if @user.authenticate(params[:existing_password])
        if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
          flash[:message] = 'Password successfully updated!'
          redirect_to root_url 
        else 
          flash[:error] = 'Password and password confirmation do not meet specifications'
          redirect_to reset_password_path
        end 
      else 
        flash[:error] = 'Incorrect existing password' 
        redirect_to reset_password_path
      end
    end
  end
  
  def current_week
    @now = now
    @cweek = @now.cweek
    @cwyear = @now.cwyear
    @week_range = week_range(@cwyear, @cweek)
  end
  
 

end
