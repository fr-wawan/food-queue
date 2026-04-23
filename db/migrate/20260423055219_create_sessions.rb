class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :jti, null: false
      t.datetime :expires_at, null: false
      t.string :user_agent
      t.string :ip_address

      t.timestamps
    end

    add_index :sessions, :jti, unique: true
  end
end
