class AddProcessedToVideos < ActiveRecord::Migration[5.0]
  def change
    add_column :videos, :processed_video, :string
  end
end
