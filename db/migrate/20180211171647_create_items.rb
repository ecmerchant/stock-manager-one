class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.string :user
      t.string :asin
      t.string :key
      t.integer :input_price
      t.float :sell_price
      t.string :title
      t.string :url
      t.string :condition
      t.string :ebay_id

      t.timestamps
    end
  end
end
