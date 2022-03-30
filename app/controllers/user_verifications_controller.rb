class UserVerificationsController < ApplicationController
  include ApplicationHelper

  before_action :require_login
  before_action :require_admin

  def index
    @user_verifications = UserVerification.left_joins(:team).order("team_name ASC").paginate(page: params[:page], per_page: per_page)
  end

  # https://www.mattmorgante.com/technology/csv
  def import
    begin
      # Easiest way to allow for a reupload in case a mistake was made.
      UserVerification.delete_all

      UserVerification.import(params[:file])
      redirect_to user_verifications_url, notice: "User Verifications successfully imported!"
    rescue ActiveRecord::RecordInvalid, RuntimeError => exception
      redirect_to user_verifications_url
      flash[:error] = "#{exception}."
    end
  end
end
