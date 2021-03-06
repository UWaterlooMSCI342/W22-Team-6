Rails.application.routes.draw do
  resources :teams

  resources :feedbacks
  root 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get 'team_view/help', to: 'teams#help'
  get 'regenerate_admin_code', to: 'options#regenerate_admin_code'
  get 'reset_password', to: 'static_pages#show_reset_password'
  post 'reset_password', to: 'static_pages#reset_password', as: 'reset_password_url'
  get 'feedbacks/:id/edit', to: 'feedbacks#edit', as: "feedback_edit"
  
  get '/download_previous', to: 'static_pages#download_previous'

  get '/download_current', to: 'static_pages#download_current'
  
  get 'teams/:id/confirm_delete_user_from_team', to: 'teams#confirm_delete_user_from_team', as: 'team_confirm_delete_delete_user_from_team'  
  get 'teams/:id/confirm_delete', to: 'teams#confirm_delete', as: 'team_confirm_delete'
  resources :teams 
  
  get 'users/:id/confirm_delete', to: 'users#confirm_delete', as: 'user_confirm_delete'
  get 'users/verifications', to: 'user_verifications#index', as: 'user_verifications'
  post 'users/verifications/import', to: 'user_verifications#import', as: 'user_verifications_import'
  
  get    '/login',  to: 'sessions#new'    
  post   '/login',  to: 'sessions#create'    
  get    '/logout', to: 'sessions#destroy' 
  get '/signup', to: 'users#new'
 

  resources :users, except: [:new] 
  resources :teams do
    post :remove_user_from_team
  end  

  patch 'feedbacks/:id', to: 'feedbacks#update'

  get 'users/:id', to: 'users#show', as: 'user_profile'
  get 'users/:id/temp_password', to: 'users#temp_password', as: 'user_temp_password'
  post 'users/:id/temp_password', to: 'users#temp_password_reset', as: 'user_temp_password_reset'
  get 'teams/:id', to: 'teams#show', as: 'team_profile'

  get 'forgot_password', to: 'users#forgot_show', as: 'forgot_pass_show_path'
  post 'forgot_password', to: 'users#forgot_password', as: 'forgot_pass_path'
  get 'forgot_password/reset', to: 'users#forgot_password_reset_show', as: 'forgot_pass_reset_show_path'
  post 'forgot_password/reset', to: 'users#forgot_password_reset', as: 'forgot_pass_reset_path'

  get 'forgot_password/reset/new_pass', to: 'users#forgot_password_new_pass_show', as: 'forgot_password_new_pass_show_path'
  post 'forgot_password/reset/new_pass', to: 'users#forgot_password_new_pass', as: 'forgot_password_new_pass_path'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end


