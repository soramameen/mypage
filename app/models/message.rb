class Message < ApplicationRecord
  belongs_to :room
  has_many :reactions, dependent: :destroy

  validates :content, presence: true
  validates :user_name, presence: true
end
