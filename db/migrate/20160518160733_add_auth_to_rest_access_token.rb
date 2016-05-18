class AddAuthToRestAccessToken < ActiveRecord::Migration
  def change
    add_column :rest_access_tokens, :provider, :string
    add_column :rest_access_tokens, :uid, :string
    add_column :rest_access_tokens, :token, :string
    add_column :rest_access_tokens, :secret, :string
  end
end
