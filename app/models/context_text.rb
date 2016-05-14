class ContextText < ActiveRecord::Base
  belongs_to :language
  has_and_belongs_to_many :users
  has_and_belongs_to_many :text_elements
  has_many :translation_in_context_texts
  has_many :translations, :through => :translation_in_context_texts
end
