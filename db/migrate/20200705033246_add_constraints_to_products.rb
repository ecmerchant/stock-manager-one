class AddConstraintsToProducts < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      ALTER TABLE products
        ADD CONSTRAINT product_upsert UNIQUE ("user", "group_id", "item_id");
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE products
        DROP CONSTRAINT product_upsert;
    SQL
  end
end
