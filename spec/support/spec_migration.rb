class SpecMigration < ActiveRecord::Migration
  def self.up
    create_table :contacts, force: true do |t|
      t.string :name
    end

    create_table :documents, force: true do |t|
      t.string :number
    end
  end

  def self.down
    drop_table :documents
    drop_table :contacts
  end
end
