class CreateTranslationInContextTexts < ActiveRecord::Migration
  def change
    create_table :translation_in_context_texts do |t|
      t.integer :position
      t.integer :selection_length
      t.references :translation, index: true, foreign_key: true
      t.references :context_text, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
