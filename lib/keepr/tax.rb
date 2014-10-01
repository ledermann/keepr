class Keepr::Tax < ActiveRecord::Base
  self.table_name = 'keepr_tax'

  validates_presence_of :name, :value

  belongs_to :keepr_account, :class_name => 'Keepr::Account'

  validate do |tax|
    tax.errors.add(:keepr_account, 'circular reference') if tax.keepr_account.keepr_tax == tax
  end
end
