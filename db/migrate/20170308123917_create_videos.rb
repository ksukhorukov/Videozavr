class CreateVideos < ActiveRecord::Migration[5.0]
  def change
    create_table :videos do |t|
      t.string :watermark
      t.integer :user_id

      t.timestamps
    end
    add_index :videos, [:user_id, :created_at]
  end
end
