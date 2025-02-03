class CreateRefreshTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :refresh_tokens, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string  :token_digest, null: false
      t.string  :jti,          null: false
      t.string  :family_id,    null: false # for rotation/reuse detection
      t.string  :user_agent
      t.string  :ip
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end
    add_index :refresh_tokens, :token_digest, unique: true
    add_index :refresh_tokens, :jti,          unique: true
    add_index :refresh_tokens, :family_id
    add_index :refresh_tokens, :expires_at
  end
end
