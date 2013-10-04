class KeeprMigration < ActiveRecord::Migration
  def self.up
    create_table :keepr_items, force: true do |t|
      t.integer    :keepr_account_id, :null => false
      t.integer    :keepr_transaction_id, :null => false
      t.decimal    :amount, :null => false
      t.references :accountable, :polymorphic => true
    end
    add_index :keepr_items, :keepr_account_id
    add_index :keepr_items, :keepr_transaction_id
    add_index :keepr_items, [:accountable_type, :accountable_id]

    create_table :keepr_transactions, force: true do |t|
      t.date     :date, :null => false
      t.string   :subject
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :keepr_transactions, :date

    create_table :keepr_accounts, force: true do |t|
      t.string     :number, :null => false
      t.string     :name, :null => false
      t.string     :kind, :null => false
      t.references :accountable, :polymorphic => true
      t.datetime   :created_at
      t.datetime   :updated_at
    end
    add_index :keepr_accounts, :number
    add_index :keepr_accounts, [:accountable_type, :accountable_id]
  end

  def self.down
    drop_table :keepr_items
    drop_table :keepr_transactions
    drop_table :keepr_accounts
  end
end
