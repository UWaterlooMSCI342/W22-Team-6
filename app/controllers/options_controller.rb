class OptionsController < ApplicationController  
  def regenerate_admin_code 
    if current_user.is_admin == true 
      Option.first.generate_admin_code 
      redirect_to root_path, notice: 'Admin code has successfully been regenerated'
    else
      redirect_to root_path, error: 'You do not have permission to update admin code'
    end
  end
end
