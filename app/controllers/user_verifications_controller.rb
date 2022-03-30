class UserVerificationsController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def index
    @user_verifications = UserVerification.paginate(page: params[:page], per_page: 10)
  end

  # https://www.mattmorgante.com/technology/csv
  def import
    begin
      # Easiest way to allow for a reupload in case a mistake was made.
      UserVerification.delete_all

      UserVerification.import(params[:file])
      redirect_to user_verifications_url, notice: "User Verifications succesfully imported!"
    rescue ActiveRecord::RecordInvalid, RuntimeError => exception
      redirect_to user_verifications_url
      flash[:error] = "#{exception}."
    end
  end
end
