class Blog < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true

  def content_html
    Kramdown::Document.new(content).to_html.html_safe
  end
end
