class CreateReactions < ActiveRecord::Migration[8.0]
  def change
    create_table :reactions do |t|
      t.string :emoji, null: false
      t.string :user_name, null: false
      t.references :message, null: false, foreign_key: true

      t.timestamps
    end

    add_index :reactions, [ :message_id, :user_name, :emoji ], unique: true
  end
end
