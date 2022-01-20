class ChangeDefaultPriorityFromFeedbacks < ActiveRecord::Migration[6.0]
  def change
    change_column_default( :feedbacks, :priority, from: 3, to: 2 )
  end
end
