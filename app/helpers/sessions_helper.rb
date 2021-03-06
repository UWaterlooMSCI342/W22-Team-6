module SessionsHelper
  # Code based on Hartl's Ruby on Rails tutorial, 6th ed.
    
  def log_in user
    session[:user_id] = user.id
    @current_user = nil
  end

  def logged_in?
     # You may have a session[:user_id], but if you don't
     # also have an entry in the database, we cannot say
     # you are logged in, for you don't exist!  This could
     # happen if an administrator deleted your account 
     # while logged_in.  
     !current_user.nil?
  end    
    
  def current_user
     if !session[:user_id].nil?
        if @current_user.nil?
            # if id not in DB, find_by returns nil
            @current_user = User.find_by(id: session[:user_id])
        end
     else
        @current_user = nil
     end
     return @current_user 
  end
    
  def log_out
      session.delete(:user_id)
      @current_user = nil
  end
  
  # Code based on https://guides.rubyonrails.org/action_controller_overview.html#filters
  def require_login
    unless logged_in?
      flash[:error] = "Please log in."
      redirect_to login_url 
    end
  end

  
  def require_temp_pass
    if logged_in?
      if (@current_user.has_to_reset_password and !@current_user.is_admin?)
        flash[:error] = "Please reset your password with the temporary password that the professor provided."
        redirect_to reset_password_path
        return
      end
    end
  end

  def is_admin?
    return @current_user.is_admin
  end

  def require_admin
    unless is_admin?
      flash[:error] = "You do not have Admin permissions."
      redirect_to root_url
    end
  end
 
end

