class TeamsController < ApplicationController
  include ApplicationHelper

  before_action :require_login
  before_action :require_admin, except: [:show, :help]
  before_action :require_temp_pass, only: [:index, :edit, :show, :update, :destroy ]
  before_action :set_team, only: [:show, :edit, :update, :destroy]

  # GET /teams
  def index
    @teams = Team.paginate(page: params[:page], per_page: per_page)
  end

  # GET /teams/1
  def show  
    if !is_admin?
      if !@current_user.teams.include? @team
        flash[:notice] = "You do not belong to this team!"
        redirect_to root_url
      end
    end 
    
    @periods = @team.feedback_by_period
    if !@periods.nil?
      @periods.each do |period| 
        period << week_range(period[0][:year], period[0][:week])
        period << Team::average_participation_rating(period[1])
        period << Team::average_effort_rating(period[1])
        period << Team::average_punctuality_rating(period[1])

        #period << @team.users_not_submitted(period[1]).map{|user| user.name}
        period << @team.users_not_submitted(period[1])
  
        wk_range = week_range(period[0][:year], period[0][:week])
        period << @team.find_priority_weighted(wk_range[:start_date], wk_range[:end_date])
      end
    end
  end

  # GET /teams/help
  def help
    render :help
  end

  # GET /teams/new
  def new
    @team = Team.new
  end

  # GET /teams/1/edit
  def edit
  end

  # POST /teams
  def create
    @team = Team.new(team_params)
    @team.user = current_user
    if @team.save
      redirect_to @team, notice: 'Team was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /teams/1
  def update
    if @team.update(team_params)
      redirect_to teams_url, notice: 'Team was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /teams/1
  def destroy
    @team.users = []
    @team.feedbacks.each do |feedback| 
      feedback.destroy 
    end
    @team.destroy
    redirect_to teams_url, notice: 'Team was successfully destroyed.'
  end

  
  def confirm_delete
    @team = Team.find(params[:id])
  end 
  
  def remove_user_from_team
    # Taken from https://stackoverflow.com/questions/12023854/rails-remove-child-association-from-parent
    @user = User.find(params[:user_id])
    @team = @user.teams.find(params[:team_id])
    @user.teams.delete(@team)
    redirect_to  root_url, notice: 'User removed successfully.'
  end
    
  def confirm_delete_user_from_team
    @user = User.find(params[:user_id])
    @team = @user.teams.find(params[:team_id])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = Team.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def team_params
      params.require(:team).permit(:team_name, :team_code)
    end
end
