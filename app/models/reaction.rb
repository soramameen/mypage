class Reaction < ApplicationRecord
  ALLOWED_EMOJIS = %w[👍 ❤️ 😂 😮 😢 😲].freeze

  belongs_to :message

  validates :emoji, presence: true, inclusion: { in: ALLOWED_EMOJIS, message: "is not allowed" }
  validates :user_name, presence: true
  validates :message, presence: true

  validates_uniqueness_of :message_id, scope: [ :user_name, :emoji ]
end
