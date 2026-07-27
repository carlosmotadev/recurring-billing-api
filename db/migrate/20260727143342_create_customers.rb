class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true } # Index direto na coluna
      t.string :document_number
      t.string :stripe_customer_id, index: { unique: true } # Index direto na coluna

      t.timestamps
    end
  end
end