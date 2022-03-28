class UserVerificationsController < ApplicationController
  # https://www.mattmorgante.com/technology/csv
  def import
    UserVerification.import(params[:file])
    redirect_to root_url, notice: "User Verifications succesfully imported!"
  end

  def index
    @user_verifications = UserVerification.paginate(page: params[:page], per_page: 10)
  end
end
