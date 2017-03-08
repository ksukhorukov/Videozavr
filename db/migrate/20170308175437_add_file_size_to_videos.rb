class AddFileSizeToVideos < ActiveRecord::Migration[5.0]
  def change
    add_column :videos, :file_size, :string
  end
end
