class CreateStocks < ActiveRecord::Migration[5.0]
  def change
    create_table :stocks do |t|
      t.string :stock_id
      t.datetime :store_date
      t.datetime :ship_date
      t.float :purchase_price
      t.string :purchase_shop
      t.string :brand
      t.string :product_id
      t.string :box
      t.string :manual
      t.string :tag
      t.text :other1
      t.text :other2
      t.string :paper_check
      t.string :condition
      t.text :note
      t.text :image

      t.timestamps
    end
  end
end
