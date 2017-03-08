class Video < ApplicationRecord
  belongs_to :user
  mount_uploader :movie, MovieUploader

  default_scope -> { order('videos.created_at DESC') }
end
