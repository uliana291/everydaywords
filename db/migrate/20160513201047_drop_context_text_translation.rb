class DropContextTextTranslation < ActiveRecord::Migration
  def change
    drop_table :context_text_translations
  end
end