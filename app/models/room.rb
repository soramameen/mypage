class Room < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :reactions, through: :messages

  validates :name, presence: true, uniqueness: true
end
