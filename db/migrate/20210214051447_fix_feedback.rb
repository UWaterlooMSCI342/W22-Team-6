class FixFeedback < ActiveRecord::Migration[6.0]
  def change
      remove_column :feedbacks, :user_id
      remove_column :feedbacks, :team_id
      change_table :feedbacks do |t|
          t.belongs_to :team, foreign_key: true
          t.belongs_to :user, foreign_key: true
      end
  end
end
