class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.references :notifiable, polymorphic: true, null: false
      t.boolean :read, default: false, null: false
      
      t.timestamps
    end
    
    add_index :notifications, [:recipient_id, :read]
  end
end
