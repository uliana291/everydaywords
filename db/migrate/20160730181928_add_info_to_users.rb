class AddInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :age, :integer
    add_column :users, :about, :string
    add_column :users, :min_starts, :integer
    add_column :users, :day_words, :integer
    add_column :users, :json_data, :text, :limit => nil
  end
end
