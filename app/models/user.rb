class User < ActiveRecord::Base
  has_many :rest_access_tokens
  has_many :user_translations
  has_and_belongs_to_many :languages, join_table: :languages_users
  has_and_belongs_to_many :context_texts, join_table: :users_context_texts
  has_many :translations, through: :user_translations
end
