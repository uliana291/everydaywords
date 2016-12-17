class CreateQas < ActiveRecord::Migration
  def change
    create_table :qas do |t|
      t.text :json_data, :limit => nil
      t.references :qa_group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
