class AddColumnToStock < ActiveRecord::Migration[5.0]
  def change
    add_column :stocks, :category, :string
  end
end
