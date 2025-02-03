class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :booking, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string  :provider, null: false                    # stripe | phonepe
      t.string  :external_id                              # PaymentIntent id, etc.
      t.string  :client_secret
      t.integer :status,  null: false, default: 0        # initiated|requires_action|succeeded|failed|refunded
      t.decimal :amount,  null: false, precision: 10, scale: 2
      t.string  :currency, null: false, default: 'USD'
      t.string  :idempotency_key, null: false
      t.jsonb   :raw_payload, null: false, default: {}
      t.datetime :paid_at
      t.datetime :refunded_at
      t.timestamps
    end
    add_index :payments, :external_id
    add_index :payments, :idempotency_key, unique: true
    add_index :payments, :status
    add_index :payments, %i[provider external_id], unique: true, where: 'external_id IS NOT NULL'
  end
end
