class AddUserToContextText < ActiveRecord::Migration
  def change
    add_reference :context_texts, :user, index: true, foreign_key: true
  end
end
