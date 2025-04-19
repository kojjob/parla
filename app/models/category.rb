class Category < ApplicationRecord
  has_many :posts, dependent: :nullify
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }
  
  # Generate a slug from the name for friendly URLs
  before_validation :generate_slug, if: :name_changed?
  
  def to_param
    slug
  end
  
  private
  
  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
