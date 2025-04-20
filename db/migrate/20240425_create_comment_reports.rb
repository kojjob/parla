class CreateCommentReports < ActiveRecord::Migration[7.0]
  def change
    create_table :comment_reports do |t|
      t.references :comment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :reason, null: false
      t.text :details
      t.integer :status, default: 0
      
      t.timestamps
    end
    
    add_index :comment_reports, [:comment_id, :user_id], unique: true
  end
end
