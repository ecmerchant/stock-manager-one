class AddHandlingTimeToSearchConditions < ActiveRecord::Migration[5.0]
  def change
    add_column :search_conditions, :handling_time, :integer
  end
end
