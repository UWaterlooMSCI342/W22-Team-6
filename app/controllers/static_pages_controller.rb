require 'csv'

class StaticPagesController < ApplicationController

  before_action :require_login
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
      
      if (@user.has_to_reset_password and !@user.is_admin?)
        flash[:notice] = "Please reset your password with the temporary password that the professor provided."
        redirect_to reset_password_path
        return
      end

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

  def download_previous
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
        response.headers['Content-Disposition'] = "attachment; filename=download_previous.csv"
      end 
    end 
  end 

  def download_current
    teams = Team.all
    @missing = {}
    @start_date = @week_range[:start_date]
    @end_date = @week_range[:end_date]
    
    teams.each do |team| 
      # @unsubmitted[:current_week][team.id] = team.users_not_submitted(team.current_feedback).map{|user| user.name}
      @missing[team.id] = team.users_not_submitted(team.current_feedback(now))
      
    end

    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=download_current.csv"
      end 
    end 
  end 

  def get_teams
    @teams = Team.all
    @unsubmitted = {current_week: {}, previous_week: {}}
    @teams.each do |team| 
      @unsubmitted[:current_week][team.id] = team.users_not_submitted(team.current_feedback)
      @unsubmitted[:previous_week][team.id] = team.users_not_submitted(team.current_feedback(now - 7.days))
      #@unsubmitted[:current_week][team.id] = team.users_not_submitted(team.current_feedback).map{|user| user.name}
      #@unsubmitted[:previous_week][team.id] = team.users_not_submitted(team.current_feedback(now - 7.days)).map{|user| user.name}
    end
  end 
  
  def show_reset_password 
    unless logged_in?
      redirect_to login_path 
    end
  end
  
  def reset_password
    unless logged_in?
      redirect_to login_path 
    else 
      @user = current_user 
      if @user.authenticate(params[:existing_password])
        if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
          flash[:notice] = 'Password successfully updated!'
          redirect_to root_url 
          @user.update(has_to_reset_password: false)
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
