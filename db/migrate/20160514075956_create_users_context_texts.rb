class CreateUsersContextTexts < ActiveRecord::Migration
  def change
    create_table :users_context_texts do |t|
      t.references :context_text, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
    end
  end
end
