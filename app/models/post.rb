class Post < ApplicationRecord
    has_one_attached :cover_image
    has_many_attached :gallery_images
    has_rich_text :body
    belongs_to :user, optional: true
    belongs_to :category, optional: true, counter_cache: true
    has_many :comments, dependent: :destroy

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

    # Simulate featured posts by selecting posts with cover images
    scope :featured, -> { with_attached_cover_image.recent }
    scope :featured_content, -> { featured.limit(5) }
    scope :by_category_with_limit, ->(category_id, limit = 4) { where(category_id: category_id).recent.limit(limit) }

    # Callbacks
    before_save :set_published_at, if: :published_changed?

    # Virtual attribute for published status
    attr_accessor :published

    def author
        user
    end

    # This method is deprecated and will be removed in the future
    # Use the new tags_list method below instead
    def tags_list_with_struct
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
        # Return the actual comments count from the database
        # This will be automatically updated by the counter cache
        comments.count
    end

    # Get approved comments only
    def approved_comments
        comments.approved.root_comments.includes(:user, :replies)
    end

    # Extract tags from the tags string
    def tags_list
        return [] unless self.tags.present?

        # Split the tags string by commas and clean up each tag
        self.tags.split(',').map(&:strip).reject(&:blank?)
    end

    # Find related posts based on category, tags, and title similarity
    def related_posts(limit = 3)
        # Get post IDs for related posts
        related_ids = find_related_post_ids(limit)

        # Return an ActiveRecord relation with the related post IDs
        Post.where(id: related_ids)
    end

    # Helper method to find related post IDs
    def find_related_post_ids(limit = 3)
        # Start with posts in the same category
        related = Post.where.not(id: self.id)
                      .where(category_id: self.category_id)
                      .published

        related_ids = related.limit(limit).pluck(:id)

        # If we don't have enough posts from the same category, add posts with similar tags
        if related_ids.size < limit && self.tags.present?
            # Extract tags from the current post
            tag_list = self.tags_list

            # Find posts that have any of these tags (excluding already found posts and self)
            tag_conditions = tag_list.map { |tag| "posts.tags LIKE '%#{tag}%'" }.join(' OR ')

            tag_related_ids = Post.where.not(id: self.id)
                                 .where.not(id: related_ids)
                                 .where(tag_conditions)
                                 .published
                                 .limit(limit - related_ids.size)
                                 .pluck(:id)

            related_ids.concat(tag_related_ids)
        end

        # If we still don't have enough posts, add recent posts
        if related_ids.size < limit
            recent_post_ids = Post.where.not(id: self.id)
                                 .where.not(id: related_ids)
                                 .published
                                 .order(created_at: :desc)
                                 .limit(limit - related_ids.size)
                                 .pluck(:id)

            related_ids.concat(recent_post_ids)
        end

        # Return the related post IDs
        related_ids.uniq.first(limit)
    end

    # Get the next post (newer post)
    def next_post
        Post.where("created_at > ?", self.created_at)
            .order(created_at: :asc)
            .first
    end

    # Get the previous post (older post)
    def previous_post
        Post.where("created_at < ?", self.created_at)
            .order(created_at: :desc)
            .first
    end

    # Class method to get popular tags
    def self.popular_tags(limit = 10)
        # Get all tags from published posts
        all_tags = published.where.not(tags: [nil, '']).pluck(:tags)

        # Split and flatten tags
        tag_array = all_tags.flat_map { |tags| tags.split(',').map(&:strip) }

        # Count occurrences of each tag
        tag_counts = tag_array.each_with_object(Hash.new(0)) { |tag, counts| counts[tag] += 1 }

        # Sort by count (descending) and take the top ones
        tag_counts.sort_by { |_tag, count| -count }.first(limit).map(&:first)
    end
end
