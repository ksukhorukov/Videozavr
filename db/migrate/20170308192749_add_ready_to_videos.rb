class AddReadyToVideos < ActiveRecord::Migration[5.0]
  def change
    add_column :videos, :ready, :boolean
  end
end
