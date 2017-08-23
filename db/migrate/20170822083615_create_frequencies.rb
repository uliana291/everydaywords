class CreateFrequencies < ActiveRecord::Migration
  def change
    create_table :frequencies do |t|
      t.string :word
      t.float :frequency
      t.integer :language

      t.timestamps null: false
    end
  end
end
