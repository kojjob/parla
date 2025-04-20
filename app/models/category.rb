class Category < ApplicationRecord
  has_many :posts, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }

  # Generate a slug from the name for friendly URLs
  before_validation :generate_slug, if: :name_changed?

  def to_param
    slug
  end

  def icon_emoji
    return nil unless respond_to?(:icon) && icon.present?

    case icon
    when 'books' then '📚'
    when 'technology' then '💻'
    when 'food' then '🍔'
    when 'travel' then '✈️'
    when 'fitness' then '🏋️'
    when 'gaming' then '🎮'
    when 'movies' then '🎬'
    when 'music' then '🎵'
    when 'mobile' then '📱'
    when 'home' then '🏠'
    when 'fashion' then '👕'
    when 'business' then '💼'
    when 'art' then '🎨'
    when 'news' then '📰'
    when 'sports' then '⚽'
    when 'nature' then '🌿'
    when 'science' then '🔬'
    when 'education' then '🧠'
    else nil
    end
  end

  def icon_emoji
    case icon
    when 'books' then '📚'
    when 'technology' then '💻'
    when 'food' then '🍔'
    when 'travel' then '✈️'
    when 'fitness' then '🏋️'
    when 'gaming' then '🎮'
    when 'movies' then '🎬'
    when 'music' then '🎵'
    when 'mobile' then '📱'
    when 'home' then '🏠'
    when 'fashion' then '👕'
    when 'business' then '💼'
    when 'art' then '🎨'
    when 'news' then '📰'
    when 'sports' then '⚽'
    when 'nature' then '🌿'
    when 'science' then '🔬'
    when 'education' then '🧠'
    else nil
    end
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
