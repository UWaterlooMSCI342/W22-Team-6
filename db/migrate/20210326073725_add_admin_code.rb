class AddAdminCode < ActiveRecord::Migration[6.0]
  def change
    change_table :options do |t|
      t.column :admin_code, :string, limit: 10, default: 'admin'
    end
  end
end
