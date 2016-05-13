class User < ActiveRecord::Base
  has_many :rest_access_tokens
  has_many :user_translations
  has_and_belongs_to_many :languages
  has_and_belongs_to_many :context_texts
  has_many :translations, through: :user_translations
end
