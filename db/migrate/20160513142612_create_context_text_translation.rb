class CreateContextTextTranslation < ActiveRecord::Migration
  def change
    create_table :context_text_translations do |t|
      t.references :translation, index: true, foreign_key: true
      t.references :context_text, index: true, foreign_key: true
    end
  end
end
