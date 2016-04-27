class KeeprMigration < ActiveRecord::Migration
  def self.up
    create_table Keepr::Group, force: true do |t|
      t.integer    :target, :null => false
      t.string     :number
      t.string     :name, :null => false
      t.boolean    :is_result, :null => false, :default => false
      t.string     :ancestry

      t.index :ancestry
    end

    create_table Keepr::Tax, force: true do |t|
      t.string     :name, :null => false
      t.string     :description
      t.decimal    :value, :precision => 8, :scale => 2, :null => false
      t.references :keepr_account, :null => false

      t.index :keepr_account_id
    end

    create_table Keepr::CostCenter, force: true do |t|
      t.string     :number, :null => false
      t.string     :name, :null => false
      t.text       :note
    end

    create_table Keepr::Account, force: true do |t|
      t.integer    :number, :null => false
      t.string     :ancestry
      t.string     :name, :null => false
      t.integer    :kind, :null => false
      t.references :keepr_group
      t.references :accountable, :polymorphic => true
      t.references :keepr_tax
      t.datetime   :created_at
      t.datetime   :updated_at

      t.index :number
      t.index :ancestry
      t.index [:accountable_type, :accountable_id]
      t.index :keepr_group_id
      t.index :keepr_tax_id
    end

    create_table Keepr::Journal, force: true do |t|
      t.string   :number
      t.date     :date, :null => false
      t.string   :subject
      t.references :accountable, :polymorphic => true
      t.text     :note
      t.boolean  :permanent, :null => false, :default => false
      t.datetime :created_at
      t.datetime :updated_at

      t.index :date
      t.index [:accountable_type, :accountable_id], :name => 'index_keepr_journals_on_accountable'
    end

    create_table Keepr::Posting, force: true do |t|
      t.references :keepr_account, :null => false
      t.references :keepr_journal, :null => false
      t.decimal    :amount, :precision => 8, :scale => 2, :null => false
      t.references :keepr_cost_center
      t.references :accountable, :polymorphic => true

      t.index :keepr_account_id
      t.index :keepr_journal_id
      t.index :keepr_cost_center_id
      t.index [:accountable_type, :accountable_id]
    end
  end

  def self.down
    drop_table Keepr::Posting
    drop_table Keepr::Journal
    drop_table Keepr::Account
    drop_table Keepr::CostCenter
    drop_table Keepr::Tax
    drop_table Keepr::Group
  end
end
