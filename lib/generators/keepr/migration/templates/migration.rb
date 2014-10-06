class KeeprMigration < ActiveRecord::Migration
  def self.up
    create_table :keepr_groups, force: true do |t|
      t.string     :target, :null => false
      t.string     :number
      t.string     :name, :null => false
      t.boolean    :is_result, :null => false, :default => false
      t.string     :ancestry
    end
    add_index :keepr_groups, :ancestry

    create_table :keepr_taxes, force: true do |t|
      t.string     :name, :null => false
      t.string     :description
      t.decimal    :value, :precision => 8, :scale => 2, :null => false
      t.references :keepr_account, :null => false
    end
    add_index :keepr_taxes, :keepr_account_id

    create_table :keepr_cost_centers, force: true do |t|
      t.string     :number, :null => false
      t.string     :name, :null => false
      t.text       :note
    end

    create_table :keepr_accounts, force: true do |t|
      t.integer    :number, :null => false
      t.string     :ancestry
      t.string     :name, :null => false
      t.string     :kind, :null => false
      t.references :keepr_group
      t.references :accountable, :polymorphic => true
      t.references :keepr_tax
      t.integer    :keepr_postings_count, :default => 0
      t.decimal    :keepr_postings_sum_amount, :precision => 8, :scale => 2, :default => 0.0
      t.datetime   :created_at
      t.datetime   :updated_at
    end
    add_index :keepr_accounts, :number
    add_index :keepr_accounts, :ancestry
    add_index :keepr_accounts, [:accountable_type, :accountable_id]
    add_index :keepr_accounts, :keepr_group_id
    add_index :keepr_accounts, :keepr_tax_id

    create_table :keepr_journals, force: true do |t|
      t.string   :number
      t.date     :date, :null => false
      t.string   :subject
      t.references :accountable, :polymorphic => true
      t.text     :note
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :keepr_journals, :date
    add_index :keepr_journals, [:accountable_type, :accountable_id], :name => 'index_keepr_journals_on_accountable'

    create_table :keepr_postings, force: true do |t|
      t.references :keepr_account, :null => false
      t.references :keepr_journal, :null => false
      t.decimal    :amount, :precision => 8, :scale => 2, :null => false
      t.references :keepr_cost_center
    end
    add_index :keepr_postings, :keepr_account_id
    add_index :keepr_postings, :keepr_journal_id
    add_index :keepr_postings, :keepr_cost_center_id
  end

  def self.down
    drop_table :keepr_postings
    drop_table :keepr_journals
    drop_table :keepr_accounts
    drop_table :keepr_groups
  end
end
