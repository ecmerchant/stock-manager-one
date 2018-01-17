class CreateCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :codes do |t|
      t.string :type
      t.string :number
      t.text :value

      t.timestamps
    end
  end
end
