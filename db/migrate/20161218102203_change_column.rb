class ChangeColumn < ActiveRecord::Migration
  change_table :user_qas do |t|
    t.change :training_history, :text
  end
end
