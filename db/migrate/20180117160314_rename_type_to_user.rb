class RenameTypeToUser < ActiveRecord::Migration[5.0]
  def change
    rename_column :codes, :type, :category
  end
end
