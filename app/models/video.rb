class Video < ApplicationRecord
  belongs_to :user
  has_many :screenshots
  mount_uploader :movie, MovieUploader

  default_scope -> { order('videos.created_at DESC') }
end
