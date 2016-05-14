class ContextText < ActiveRecord::Base
  belongs_to :language
  has_and_belongs_to_many :users, :join_table => :users_context_texts
  has_and_belongs_to_many :text_elements, :join_table => :text_element_context_texts
  has_many :translation_in_context_texts
  has_many :translations, :through => :translation_in_context_texts
end
