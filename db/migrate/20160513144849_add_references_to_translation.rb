class AddReferencesToTranslation < ActiveRecord::Migration
  def change
    add_reference :translations, :original, index: true
    add_reference :translations, :translated_one, index: true

    add_foreign_key :translations, :text_elements, column: :original_id
    add_foreign_key :translations, :text_elements, column: :translated_one_id
  end
end
