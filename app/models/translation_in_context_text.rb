class TranslationInContextText < ActiveRecord::Base
  belongs_to :translation
  belongs_to :context_text
  belongs_to :user
end
