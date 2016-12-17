class Qa < ActiveRecord::Base
  belongs_to :qa_group
  has_many :user_qas
end
