class AddColumnPlaceToStock < ActiveRecord::Migration[5.0]
  def change
    add_column :stocks, :place, :string
  end
end
