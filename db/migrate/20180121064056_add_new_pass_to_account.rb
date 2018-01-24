class AddNewPassToAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :new_password, :string
    add_column :accounts, :new_password_confirmation, :string
  end
end
