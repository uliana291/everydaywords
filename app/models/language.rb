class Language < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :users, join_table: :languages_users
  has_many :context_texts
  has_many :text_elements
end
