class FeedbacksController < ApplicationController
  helper_method :sort_column, :sort_direction

  before_action :require_login
  # we no longer want feedbacks :show, :edit, :update for just the admin (teacher)
  before_action :require_admin, only: [:index, :destroy] 
  before_action :get_user_detail
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]
        
  def get_user_detail
    @user = current_user
  end

  # GET /feedbacks
  def index
    @feedbacks = Feedback.left_joins(:user, :team).order("#{sort_column} #{sort_direction}")
  end

  # GET /feedbacks/1
  def show
  end

  # GET /feedbacks/new
  def new
    @feedback = Feedback.new
  end

  # GET /feedbacks/1/edit
  def edit
    @feedback = Feedback.find(params[:id])
    render :edit
  end

  # POST /feedbacks
  def create
      
    team_submissions = @user.one_submission_teams
      
    @feedback = Feedback.new(feedback_params)
    
    @feedback.timestamp = @feedback.format_time(now)
    @feedback.user = @user
    @feedback.team = @user.teams.first
    @feedback.priority = @feedback.calculate_priority
    if team_submissions.include?(@feedback.team)
        redirect_to root_url, notice: 'You have already submitted feedback for this team this week.'
    elsif @feedback.save
      redirect_to root_url, notice: "Feedback was successfully created. Time created: #{@feedback.timestamp}. Priority Level: #{@feedback.get_priority_word}."
    else
      render :new
    end
  end

  # PATCH/PUT /feedbacks/1
  def update
    if @feedback.update(feedback_params)
      redirect_to @feedback, notice: 'Feedback was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /feedbacks/:id
  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy
    redirect_to feedbacks_url, notice: 'Feedback was successfully destroyed.'
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feedback
      @feedback = Feedback.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def feedback_params
      #removed :rating and replaced it with the individual rating fields to match the updated model
      params.require(:feedback).permit(:participation_rating, :effort_rating, :punctuality_rating, :comments)
    end

    # Sanitizes the sorting direction to stop user from sorting by unknown values (defaults by ascending).
    def sort_direction
      return ApplicationHelper::SORTABLE_DIRECTIONS.include?(params[:direction]) ? params[:direction] : ApplicationHelper::ASCENDING
    end

    # Sanitizes the sorting column to stop user from sorting by unknown columns (defaults by student name).
    def sort_column
      allowable_columns = ["name", "team_name"].concat(Feedback.column_names)
      return allowable_columns.include?(params[:sort]) ? params[:sort] : "name"
    end
end
