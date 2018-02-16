class CreateSearchKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :search_keys do |t|
      t.string :user
      t.string :asin
      t.string :key
      t.integer :price

      t.timestamps
    end
  end
end
