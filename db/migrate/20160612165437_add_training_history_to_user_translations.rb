class AddTrainingHistoryToUserTranslations < ActiveRecord::Migration
  def change
    add_column :user_translations, :training_history, :text, :limit => nil
  end
end
