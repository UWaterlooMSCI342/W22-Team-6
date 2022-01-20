class TeamsUsersAssociation < ActiveRecord::Migration[6.0]
  def change
    create_table :teams_users, id: false do |t|
      t.belongs_to :team
      t.belongs_to :user
      t.timestamps
    end
      
    add_foreign_key :teams_users, :users
    add_foreign_key :teams_users, :teams
  end
end
