class CreateUserQas < ActiveRecord::Migration
  def change
    create_table :user_qas do |t|
      t.references :user, index: true, foreign_key: true
      t.references :qa, index: true, foreign_key: true
      t.string :learning_stage
      t.datetime :next_training_at
      t.string :training_history

      t.timestamps null: false
    end
  end
end
