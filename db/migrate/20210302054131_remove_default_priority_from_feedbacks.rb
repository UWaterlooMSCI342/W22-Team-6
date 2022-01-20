class RemoveDefaultPriorityFromFeedbacks < ActiveRecord::Migration[6.0]
  def change
    change_column_default( :feedbacks, :priority, from: 2, to: 3 )
  end
end
