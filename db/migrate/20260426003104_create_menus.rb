class CreateMenus < ActiveRecord::Migration[8.1]
  def change
    create_table :menus do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :position, default: 0
      t.integer :status, default: 0, null: false
      t.timestamps
    end
  end
end
