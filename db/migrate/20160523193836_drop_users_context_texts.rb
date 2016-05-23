class DropUsersContextTexts < ActiveRecord::Migration
  def up
    drop_table :users_context_texts
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
