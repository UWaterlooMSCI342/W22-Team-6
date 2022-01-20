class AddUserFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :teams, :users
  end
end
