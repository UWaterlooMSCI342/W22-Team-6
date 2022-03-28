class UsersController < ApplicationController
  before_action :require_login, only: [:index, :edit, :show, :update, :destroy]
  before_action :require_admin, only: [:index, :destroy]
  before_action :require_access, only: [:show]
  before_action :require_access_edit, only: [:edit]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end

  # GET /users/1
  def show
  end

  # GET /signup
  def new
    if logged_in? 
      redirect_to root_url 
    end 
    
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create    
    final_user_params = user_params.except(:team_code)
        
    @user = User.new(final_user_params)
    @user.valid?

    #team_code is blank
    if user_params[:team_code].nil? or user_params[:team_code].size==0 
      @user.errors.add :teams, :invalid, message: "code cannot be blank" 
    else
      if user_params[:team_code] == Option.first.admin_code
        @user.is_admin = true
        @user.valid?
      else
        @user.is_admin = false
        @user.valid?
        team = Team.find_by(team_code: user_params[:team_code])

        #team_code is not valid 
        if team.nil?
          @user.errors.add :teams, :invalid, message: "code does not exist"
        else 
          @user.teams = [team]
        end    
      end
    end 

    if @user.errors.size == 0
      @user.save
      log_in @user
      redirect_to root_url, notice: 'User was successfully created.'
    else    
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    # update only the first_name, last_name, and email attributes
    # (ignore password validations because those are not being changed)
    if @user.update({ skip_password: true, first_name: user_params[:first_name], last_name: user_params[:last_name], email: user_params[:email] })
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    if current_user.is_admin?
      if @user == current_user
        log_out
      end
      @user.destroy
      redirect_to users_url, notice: 'User was successfully destroyed.'
    else
      redirect_to root_url, notice: 'You do not have permission to delete users.'
    end
  end
  
  def confirm_delete
    @user = User.find(params[:id])
  end 

  # GET for show password page
  def forgot_show

  end

  # POST for reset password
  def forgot_password
    email = params[:email]
    @user = User.where(email: email)

    if email.empty?
      flash[:error] = "Email can't be blank!"
      redirect_to forgot_pass_show_path_path
    elsif @user.empty?
      flash[:error] = "Email doesn't exist!"
      redirect_to forgot_pass_show_path_path
    else
      redirect_to forgot_pass_reset_show_path_path(email: email)
    end

  end
  
  def check_for_correct_pass(question1, question2, answer_1, answer_2, user_email)
 
    if answer_1 == question1 and answer_2 == question2
      redirect_to forgot_password_new_pass_show_path_path(email: user_email)
    else
      redirect_to root_url
      flash[:error] = "It seems that you have forgotten your password and security question. Please contact you professor for a new password."
    end 

  end


  # POST for show security question page
  def forgot_password_reset
    user_email = params[:email]
   
    @user = User.where(email: user_email)
    answer_one = @user.first.security_q_one
    answer_two = @user.first.security_q_two
    answer_three = @user.first.security_q_three

    if !(params[:security_q_one].present?)
      question_2 = params[:security_q_two]
      question_3 = params[:security_q_three]

      check_for_correct_pass(question_2, question_3, answer_two, answer_three, user_email)

    elsif !(params[:security_q_two].present?)
      question_1 = params[:security_q_one]
      question_3 = params[:security_q_three]

      check_for_correct_pass(question_1, question_3, answer_one, answer_three, user_email)

    elsif !(params[:security_q_three].present?)
      question_1 = params[:security_q_one]
      question_2 = params[:security_q_two]
  
      check_for_correct_pass(question_1, question_2, answer_one, answer_two, user_email)
    end 

  end

  def forgot_password_new_pass_show
    @user_email = params[:email]
    @user = User.where(email: @user_email)

    render :forgot_password_new_pass
  end

  def forgot_password_new_pass
    
    email = params[:email]
    @user = User.where(email: email) 
    pass = params[:password]
    pass_conform = params[:password_confirmation]
    
    if pass != pass_conform
      flash[:error] = 'Password and password confirmation do not meet specifications'
      redirect_to forgot_password_new_pass_show_path_url(email: email)

    elsif pass.length <6
      flash[:error] = 'Password and password confirmation do not meet specifications'
      redirect_to forgot_password_new_pass_show_path_url(email: email)

    elsif @user.update(password: pass, password_confirmation: pass_conform)
      flash[:notice] = 'Password successfully updated! Please Login.'
      redirect_to root_url 
    else 
      flash[:error] = 'Password and password confirmation do not meet specifications'
      redirect_to forgot_password_new_pass_show_path_url(email: email)
    end 
  end


  # GET for show security question page
  def forgot_password_reset_show
   
    @user_email = params[:email]
    # puts user_email
    @user = User.where(email: @user_email)

    answer_one = @user.first.security_q_one
    answer_two = @user.first.security_q_two
    answer_three = @user.first.security_q_three

    if !(answer_one.present? and answer_two.present? and answer_three.present?)
      redirect_to root_url 
      flash[:error] = "It seems that you do not have security questions setup. Please try contacting your professor for a new password"
      return
    end

    q_list = [:security_q_one, :security_q_two, :security_q_three]
    @random_q_1 = q_list.sample
    @random_q_2 = q_list.sample

    while @random_q_1 == @random_q_2
      @random_q_2 = q_list.sample
    end

    question_1 = params[@random_q_1]
    question_2 = params[@random_q_2]
    

    question_text = {"security_q_one" => "What is the name of the city you were from?", 
                    "security_q_two" => "What is the name of the high school you attended?",
                    "security_q_three" => "What was your favourite food as a child?"}

    @q_1_text = question_text[@random_q_1.to_s]
    @q_2_text = question_text[@random_q_2.to_s]

    render :forgot_password_reset
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    # Should use later (ignoring this for now)
    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, :team_code, :security_q_three, :security_q_two, :security_q_one)
    end

    def require_access
      # if user is a student, they can access only their own profile
      if !is_admin?
        set_user

        if @user.attributes != @current_user.attributes
          flash[:notice] = "You do not have permission to access someone else's profile."
          redirect_to root_url
        end
      end
    end

    def require_access_edit
      # user can edit only their own profile
      set_user
      
      if @user.attributes != @current_user.attributes
        flash[:notice] = "You do not have permission to edit someone else's profile."
        redirect_to root_url
      end
    end
end
