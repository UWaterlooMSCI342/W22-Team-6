class DeleteCascadeUsers < ActiveRecord::Migration[6.0]
  def change
     # add cascading delete to teams
     remove_foreign_key :teams, :users
     add_foreign_key :teams, :users, on_delete: :cascade
    
     # add cascading delete to feedbacks
     remove_foreign_key :feedbacks, :users
     add_foreign_key :feedbacks, :users, on_delete: :cascade
  end
end