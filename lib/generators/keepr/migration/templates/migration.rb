# frozen_string_literal: true

class KeeprMigration < Keepr::MIGRATION_BASE_CLASS
  def self.up
    create_table Keepr::Group, force: true do |t|
      t.integer    :target, null: false
      t.string     :number
      t.string     :name, null: false
      t.boolean    :is_result, null: false, default: false
      t.string     :ancestry, index: true
    end

    create_table Keepr::Tax, force: true do |t|
      t.string     :name, null: false
      t.string     :description
      t.decimal    :value, precision: 8, scale: 2, null: false
      t.references :keepr_account, null: false, index: true
    end

    create_table Keepr::CostCenter, force: true do |t|
      t.string     :number, null: false
      t.string     :name, null: false
      t.text       :note
    end

    create_table Keepr::Account, force: true do |t|
      t.integer    :number, null: false, index: true
      t.string     :ancestry, index: true
      t.string     :name, null: false
      t.integer    :kind, null: false
      t.references :keepr_group, index: true
      t.references :accountable, polymorphic: true, index: true
      t.references :keepr_tax, index: true
      t.datetime   :created_at
      t.datetime   :updated_at
    end

    create_table Keepr::Journal, force: true do |t|
      t.string   :number
      t.date     :date, null: false, index: true
      t.string   :subject
      t.references :accountable, polymorphic: true, index: true
      t.text     :note
      t.boolean  :permanent, null: false, default: false
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table Keepr::Posting, force: true do |t|
      t.references :keepr_account, null: false, index: true
      t.references :keepr_journal, null: false, index: true
      t.decimal    :amount, precision: 8, scale: 2, null: false
      t.references :keepr_cost_center, index: true
      t.references :accountable, polymorphic: true, index: true
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
