class Post < ApplicationRecord
    has_one_attached :cover_image
    has_many_attached :gallery_images
    has_rich_text :body
    belongs_to :user, optional: true
    belongs_to :category, optional: true, counter_cache: true

    # Basic scopes
    scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
    scope :published, -> { where.not(published_at: nil).where('published_at <= ?', Time.current) }
    scope :recent, -> { order(created_at: :desc) }
    scope :oldest, -> { order(created_at: :asc) }

    # Advanced scopes
    scope :with_images, -> {
      joins("LEFT JOIN active_storage_attachments ON " +
            "active_storage_attachments.record_id = posts.id AND " +
            "active_storage_attachments.record_type = 'Post' AND " +
            "active_storage_attachments.name = 'cover_image'")
      .where.not(active_storage_attachments: { id: nil })
      .distinct
    }

    scope :featured_content, -> { recent.with_attached_cover_image.limit(5) }
    scope :by_category_with_limit, ->(category_id, limit = 4) { where(category_id: category_id).recent.limit(limit) }

    # Callbacks
    before_save :set_published_at, if: :published_changed?

    # Virtual attribute for published status
    attr_accessor :published

    def author
        user
    end

    def tags_list
        return [] if tags.blank?
        tags.split(',').map(&:strip).map do |tag_name|
            # Using a simple Struct instead of OpenStruct
            Struct.new(:name).new(tag_name)
        end
    end

    def published?
        published_at.present? && published_at <= Time.current
    end

    def published=(value)
        @published = ActiveModel::Type::Boolean.new.cast(value)
    end

    def published_changed?
        return false if @published.nil?
        published? != @published
    end

    private

    def set_published_at
        self.published_at = @published ? Time.current : nil
    end

    public

    # Helper methods for UI display
    def excerpt(length = 150)
        ActionView::Base.full_sanitizer.sanitize(body.to_s).truncate(length)
    end

    def reading_time
        words_per_minute = 200
        text = ActionView::Base.full_sanitizer.sanitize(body.to_s)
        words = text.split.size
        minutes = (words / words_per_minute).floor
        minutes = 1 if minutes < 1
        minutes
    end

    def comments_count
        # This is a placeholder method for the comments count
        # Replace with actual implementation when you add comments
        0
    end
end
