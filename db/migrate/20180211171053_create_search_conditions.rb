class CreateSearchConditions < ActiveRecord::Migration[5.0]
  def change
    create_table :search_conditions do |t|
      t.string :user
      t.string :app_id
      t.integer :low_price
      t.integer :high_price
      t.string :category_id
      t.string :item_condition
      t.string :sales_type
      t.string :rank
      t.string :score

      t.timestamps
    end
  end
end
