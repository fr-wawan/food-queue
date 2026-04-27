class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :order_number, null: false
      t.integer :status, default: 0
      t.text :note
      t.decimal :total_price, precision: 10, scale: 2, default: 0
      t.timestamps
    end
  end
end
