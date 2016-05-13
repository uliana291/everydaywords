class TextElement < ActiveRecord::Base
  belongs_to :language
  has_and_belongs_to_many :context_texts
  has_many :originals, class_name: 'Translation', foreign_key: 'original_id'
  has_many :translated_ones, class_name: 'Translation', foreign_key: 'translated_one_id'
end
