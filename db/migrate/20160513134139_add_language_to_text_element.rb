class AddLanguageToTextElement < ActiveRecord::Migration
  def change
    add_reference :text_elements, :language, index: true, foreign_key: true
  end
end
