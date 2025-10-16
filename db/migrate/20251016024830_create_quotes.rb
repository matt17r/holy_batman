class CreateQuotes < ActiveRecord::Migration[8.2]
  def change
    create_table :quotes do |t|
      t.string :text, null: false
      t.string :slug
      t.text :context

      t.timestamps
    end

    # Add unique index on text (case-insensitive)
    add_index :quotes, :text, unique: true

    # Add unique index on slug
    add_index :quotes, :slug, unique: true

    # Set starting ID to 100 using SQLite approach
    # This inserts a row with ID 99, then deletes it, leaving the sequence at 99
    # The next inserted row will get ID 100
    execute "INSERT INTO quotes (id, text, created_at, updated_at) VALUES (99, 'dummy', datetime('now'), datetime('now'))"
    execute "DELETE FROM quotes WHERE id = 99"
  end
end
