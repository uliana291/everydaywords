class CreateQaGroups < ActiveRecord::Migration
  def change
    create_table :qa_groups do |t|
      t.string :name
      t.text :question_template
      t.text :answer_template
      t.string :display_name

      t.timestamps null: false
    end
  end
end
