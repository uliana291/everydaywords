class AddUserToRestAccessToken < ActiveRecord::Migration
  def change
    add_reference :rest_access_tokens, :user, index: true, foreign_key: true
  end
end
