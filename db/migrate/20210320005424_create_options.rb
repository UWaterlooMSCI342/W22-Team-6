class CreateOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :options do |t|
      t.boolean :reports_toggled, :default => false

      t.timestamps
    end
  end
end
