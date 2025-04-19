class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.decimal :discounted_price
      t.integer :stock_quantity
      t.string :sku
      t.string :barcode
      t.decimal :weight
      t.string :dimensions
      t.string :condition
      t.string :brand
      t.boolean :featured
      t.string :currency
      t.string :country_of_origin
      t.boolean :available_in_ghana
      t.boolean :available_in_nigeria
      t.string :shipping_time
      # t.references :category, null: false, foreign_key: true
      # t.references :seller, null: false, foreign_key: true
      t.boolean :published
      t.datetime :published_at
      t.string :meta_title
      t.text :meta_description
      t.boolean :is_digital
      t.string :status

      t.timestamps
    end
    add_index :products, :name
    add_index :products, :description
    add_index :products, :price
    add_index :products, :discounted_price
    add_index :products, :stock_quantity
    add_index :products, :sku, unique: true
    add_index :products, :barcode, unique: true
    add_index :products, :weight
    add_index :products, :dimensions
    add_index :products, :condition
    add_index :products, :brand
    add_index :products, :featured
    add_index :products, :currency
    add_index :products, :country_of_origin
    add_index :products, :available_in_ghana
    add_index :products, :available_in_nigeria
    add_index :products, :shipping_time
    add_index :products, :published
    add_index :products, :published_at
    add_index :products, :meta_title
    add_index :products, :meta_description
    add_index :products, :is_digital
    add_index :products, :status
  end
end
