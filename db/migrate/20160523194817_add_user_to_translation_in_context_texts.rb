class AddUserToTranslationInContextTexts < ActiveRecord::Migration
  def change
    add_reference :translation_in_context_texts, :user, index: true, foreign_key: true
  end
end
