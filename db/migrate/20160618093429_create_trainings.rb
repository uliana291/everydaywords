class CreateTrainings < ActiveRecord::Migration
  def change
    create_table :trainings do |t|

      t.string :kind
      t.string :state
      t.text :json_data, :limit => nil
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
