class CreatePlans < ActiveRecord::Migration[7.0]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.integer :price_cents, null: false, default: 0
      t.integer :interval, null: false, default: 0
      t.string :stripe_price_id, index: { unique: true }

      t.timestamps
    end
  end
end