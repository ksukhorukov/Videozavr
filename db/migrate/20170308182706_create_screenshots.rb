class CreateScreenshots < ActiveRecord::Migration[5.0]
  def change
    create_table :screenshots do |t|
      t.string :file_path
      t.integer :video_id

      t.timestamps
    end
  end
end
