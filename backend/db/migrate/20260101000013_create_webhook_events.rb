class CreateWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_events, id: :uuid do |t|
      t.string :provider,    null: false
      t.string :external_id, null: false
      t.string :event_type,  null: false
      t.jsonb  :payload,     null: false, default: {}
      t.integer :status,     null: false, default: 0 # received|processed|failed
      t.text   :error
      t.datetime :processed_at
      t.timestamps
    end
    add_index :webhook_events, %i[provider external_id], unique: true
    add_index :webhook_events, :status
  end
end
