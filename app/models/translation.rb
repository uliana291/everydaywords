class Translation < ActiveRecord::Base
  has_many :user_translations
  has_many :users, through: :user_translations
  has_many :translation_in_context_texts
  has_many :context_texts, through: :translation_in_context_texts
  belongs_to :original, class_name: 'TextElement', foreign_key: 'original_id'
  belongs_to :translated_one, class_name: 'TextElement', foreign_key: 'translated_one_id'
end
