class Like < ApplicationRecord
  validates :page_identifier, presence: true, uniqueness: true

  def self.increment_for(page_id)
    like = find_or_create_by(page_identifier: page_id)
    like.increment!(:count)
    like.count
  end
end
