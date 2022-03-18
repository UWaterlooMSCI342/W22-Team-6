class FeedbacksController < ApplicationController
  helper_method :sort_column, :sort_direction

  before_action :require_login
  # we no longer want feedbacks :show, :edit, :update for just the admin (teacher)
  before_action :require_admin, only: [:index, :destroy] 
  before_action :require_access, only: [:show, :edit]
  before_action :get_user_detail
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]

  # GET /feedbacks
  def index
    @feedbacks = Feedback.filter_and_sort(params, sort_column, sort_direction)
  end

  # GET /feedbacks/1
  def show
  end

  # GET /feedbacks/new
  def new
    if @user.has_submitted
      redirect_to root_url
      flash[:error] = "You cannot acces this page after submitting your feedback for the week."
    else 
      @feedback = Feedback.new
    end 
  end

  # GET /feedbacks/1/edit
  def edit
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
      redirect_to @feedback, notice: "Feedback was successfully created. Time created: #{@feedback.display_timestamp}. Priority Level: #{@feedback.get_priority_word}."
    else
      render :new
    end
  end

  # PATCH/PUT /feedbacks/1
  def update
    if !(@feedback.is_from_this_week?)
      redirect_to root_url
      flash[:error] = "You cannot edit feedback from previous weeks."
    elsif @feedback.update(feedback_params)
      @feedback.update({ timestamp: @feedback.format_time(now), priority: @feedback.calculate_priority })
      redirect_to @feedback, notice: "Feedback was successfully updated. Time updated: #{@feedback.display_timestamp}. Priority Level: #{@feedback.get_priority_word}."
    else
      render :edit
    end
  end

  # DELETE /feedbacks/:id
  def destroy
    @feedback.destroy
    redirect_to feedbacks_url, notice: 'Feedback was successfully destroyed.'
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feedback
      @feedback = Feedback.find(params[:id])
    end

    def get_user_detail
      @user = current_user
    end

    # Students should only be able to access their own feedback for this week.
    def require_access
      if !is_admin?
        set_feedback

        if (@current_user.feedbacks.exclude? @feedback) or !(@feedback.is_from_this_week?)
          flash[:error] = "You do not have permission to access this feedback."
          redirect_to root_url
        end
      end
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

    # Sanitizes the sorting column to stop user from sorting by unknown columns (defaults by student first name).
    def sort_column
      allowable_columns = ["first_name", "last_name", "team_name"].concat(Feedback.column_names)
      return allowable_columns.include?(params[:sort]) ? params[:sort] : "first_name"
    end
end
