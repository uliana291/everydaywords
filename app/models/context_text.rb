class ContextText < ActiveRecord::Base
  belongs_to :language
  has_and_belongs_to_many :users
  has_and_belongs_to_many :text_elements
  has_and_belongs_to_many :translations
end
