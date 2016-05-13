class CreateTextElements < ActiveRecord::Migration
  def change
    create_table :text_elements do |t|
      t.string :value
      t.string :part_of_speech

      t.timestamps null: false
    end
  end
end
