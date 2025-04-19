json.extract! post, :id, :title, :body, :user_id, :published_at, :tags, :cover_image_url, :created_at, :updated_at
json.url post_url(post, format: :json)
