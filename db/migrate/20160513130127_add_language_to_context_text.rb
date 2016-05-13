class AddLanguageToContextText < ActiveRecord::Migration
  def change
    add_reference :context_texts, :language, index: true, foreign_key: true
  end
end
