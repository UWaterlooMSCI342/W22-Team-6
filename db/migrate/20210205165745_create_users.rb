class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, limit: 255 
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :security_q_one, limit: 255
      t.string :security_q_two, limit: 255
      t.string :security_q_three, limit: 255
      t.integer :user_id
      t.boolean :is_admin, default: false
      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
