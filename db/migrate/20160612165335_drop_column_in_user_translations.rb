class DropColumnInUserTranslations < ActiveRecord::Migration
  def change
    remove_column :user_translations, :training_history
  end
end
