class CreateLanguageContextText < ActiveRecord::Migration
  def change
    create_table :language_context_texts do |t|
      t.references :language, index: true, foreign_key: true
      t.references :context_text, index: true, foreign_key: true
    end
  end
end
