class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :user
      t.string :item_id
      t.text :title
      t.float :price
      t.string :shipping
      t.string :item_url
      t.text :item_specs
      t.string :group_id

      t.timestamps
    end
  end
end
