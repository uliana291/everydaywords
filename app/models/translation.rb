class Translation < ActiveRecord::Base
  has_many :user_translations
  has_many :users, through: :user_translations
  has_and_belongs_to_many :context_texts
  belongs_to :original, class_name: 'TextElement', foreign_key: 'original_id'
  belongs_to :translated_one, class_name: 'TextElement', foreign_key: 'translated_one_id'
end
