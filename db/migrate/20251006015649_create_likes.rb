class CreateLikes < ActiveRecord::Migration[8.0]
  def change
    create_table :likes do |t|
      t.string :page_identifier
      t.integer :count

      t.timestamps
    end
  end
end
