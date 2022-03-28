class UserVerificationsController < ApplicationController
  # def upload_verification
  #   verifications = []
  #   CSV.foreach(params[:csv_file], headers: true) do |row|
  #     verifications << row.to_h
  #   end
  #   UserVerification.import(verifications)

  #   respond_to do |format|
  #     format.html
  #     format.csv do
  #       response.headers['Content-Type'] = 'text/csv'
  #       response.headers['Content-Disposition'] = "attachment; filename=download_previous.csv"
  #     end 
  #   end 
  # end

  # https://www.mattmorgante.com/technology/csv
  def import
    UserVerification.import(params[:file])
    redirect_to root_url, notice: "User Verifications succesfully imported!"
  end
end
