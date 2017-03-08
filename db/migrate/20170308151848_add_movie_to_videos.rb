class AddMovieToVideos < ActiveRecord::Migration[5.0]
  def change
    add_column :videos, :movie, :string
  end
end
