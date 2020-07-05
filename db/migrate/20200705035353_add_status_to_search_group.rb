class AddStatusToSearchGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :search_groups, :status, :string
  end
end
