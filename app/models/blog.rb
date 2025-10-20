class Blog < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true

  def content_html
    Kramdown::Document.new(content).to_html.html_safe
  end

  def blog_number
    Blog.where("created_at <= ?", created_at).count
  end

  def numbered_title
    "##{blog_number} #{title}"
  end
end
