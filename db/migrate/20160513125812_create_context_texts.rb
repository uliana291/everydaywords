class CreateContextTexts < ActiveRecord::Migration
  def change
    create_table :context_texts do |t|
      t.string :url
      t.string :title
      t.text :whole_text

      t.timestamps null: false
    end
  end
end
