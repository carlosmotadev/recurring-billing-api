class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :subscription, null: false, foreign_key: true
      t.integer :amount_cents
      t.integer :status
      t.string :stripe_invoice_id
      t.datetime :paid_at

      t.timestamps
    end
  end
end
