class CreateTextElementContextText < ActiveRecord::Migration
  def change
    create_table :text_element_context_texts do |t|
      t.references :text_element, index: true, foreign_key: true
      t.references :context_text, index: true, foreign_key: true
    end
  end
end
