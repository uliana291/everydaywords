class CreateLanguagesUsers < ActiveRecord::Migration
  def change
    create_table :languages_users do |t|
      t.references :user, index: true, foreign_key: true
      t.references :language, index: true, foreign_key: true
    end
  end
end
