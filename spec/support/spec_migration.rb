class SpecMigration < ActiveRecord::Migration
  def self.up
    create_table Contact, force: true do |t|
      t.string :name
    end

    create_table Ledger, force: true do |t|
      t.string :bank_name
    end

    create_table Document, force: true do |t|
      t.string :number
    end
  end

  def self.down
    drop_table Document
    drop_table Ledger
    drop_table Contact
  end
end
