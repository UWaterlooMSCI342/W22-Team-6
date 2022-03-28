class CreateUserVerifications < ActiveRecord::Migration[6.1]
  def change
    create_table :user_verifications do |t|
      t.string :email, null: false, limit: 255
      t.belongs_to :team, foreign_key: true
      t.timestamps
    end
    add_index :user_verifications, :email, unique: true
  end
end
