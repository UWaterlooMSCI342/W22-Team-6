class CreateReports < ActiveRecord::Migration[6.0]
  def change
    create_table :reports do |t|
      t.integer :reporter_id, null: false
      t.integer :reportee_id, null: false
      t.string :description, limit: 500

      t.timestamps
    end
    add_foreign_key :reports, :users, column: :reporter_id
    add_index :reports, :reporter_id
    add_foreign_key :reports, :users, column: :reportee_id
    add_index :reports, :reportee_id
  end
end
