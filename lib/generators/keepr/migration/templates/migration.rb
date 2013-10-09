class KeeprMigration < ActiveRecord::Migration
  def self.up
    create_table :keepr_postings, force: true do |t|
      t.integer    :keepr_account_id, :null => false
      t.integer    :keepr_journal_id, :null => false
      t.decimal    :amount, :null => false
    end
    add_index :keepr_postings, :keepr_account_id
    add_index :keepr_postings, :keepr_journal_id

    create_table :keepr_journals, force: true do |t|
      t.date     :date, :null => false
      t.string   :subject
      t.references :accountable, :polymorphic => true
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :keepr_journals, :date
    add_index :keepr_journals, [:accountable_type, :accountable_id], :name => 'index_keepr_journals_on_accountable'

    create_table :keepr_accounts, force: true do |t|
      t.integer    :number, :null => false
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
    drop_table :keepr_postings
    drop_table :keepr_journals
    drop_table :keepr_accounts
  end
end
