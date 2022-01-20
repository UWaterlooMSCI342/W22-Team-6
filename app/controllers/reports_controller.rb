class ReportsController < ApplicationController
  before_action :require_login
  before_action :require_admin, only: [:show, :update, :destroy]
    
  # GET /reports
  def index
    if Option.first.reports_toggled
      @reports = Report.all
    end
  end
  
  # POST /reports
  def create
      if Option.first.reports_toggled
        @report = Report.new(report_params)
        if @report.save
          redirect_to root_path, notice: 'Report was successfully created.'
        else
          render :new
        end
      else
        redirect_to root_path, notice: 'Reports are disabled.'
      end
  end

  # GET /reports/new
  def new
    if Option.first.reports_toggled
      @report = Report.new
    end
  end

  def edit
  end

  def show

  end

  # PATCH/PUT /reports/1
  def update
    redirect_to root_path, notice: 'Not currently in use'
    #if Option.first.reports_toggled
    #  if @report.update(report_params)
    #    redirect_to @root_path, notice: 'Report was successfully updated.'
    #  else
    #    render :edit
    #  end
    #else
    #  redirect_to root_path, notice: 'Reports are disabled.'
    #end
  end

    
  # DELETE /feedbacks/1
  def destroy
  end
  
    
  helper_method :get_students_except_self
  def get_students_except_self
      return User.where.not(id: current_user.id).where.not(is_admin: true)
  end
    
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(reports[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def report_params
      params.require(:report).permit(:reporter_id, :reportee_id, :priority, :description)
    end
  
    
    def users_except_self
        return User.where.not(id: id)
    end
end
