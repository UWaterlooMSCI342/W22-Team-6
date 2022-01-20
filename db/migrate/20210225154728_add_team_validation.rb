class AddTeamValidation < ActiveRecord::Migration[6.0]
  def change
    add_index :teams, :team_code, unique: true
  end
end
