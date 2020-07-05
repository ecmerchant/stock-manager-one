class CreateSearchGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :search_groups do |t|
      t.string :user
      t.string :group_id
      t.text :query
      t.integer :low_price
      t.integer :high_price
      t.string :category_id
      t.string :item_condition
      t.string :sales_type
      t.string :rank
      t.string :score
      t.integer :handling_time

      t.timestamps
    end
  end
end
