class UserVerificationsController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def index
    @user_verifications = UserVerification.paginate(page: params[:page], per_page: 10)
  end

  # https://www.mattmorgante.com/technology/csv
  def import
    # Assumes CSV file imported is correctly formatted.
    begin
      UserVerification.delete_all
      UserVerification.import(params[:file])
      redirect_to user_verifications_url, notice: "User Verifications succesfully imported!"
    rescue ActiveRecord::RecordInvalid => exception
      redirect_to user_verifications_url
      flash[:error] = "#{exception} for a row."
    end
  end
end
