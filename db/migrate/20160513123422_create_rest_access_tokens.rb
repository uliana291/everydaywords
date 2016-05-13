class CreateRestAccessTokens < ActiveRecord::Migration
  def change
    create_table :rest_access_tokens do |t|
      t.string :value

      t.timestamps null: false
    end
  end
end
