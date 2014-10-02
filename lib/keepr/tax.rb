class Keepr::Tax < ActiveRecord::Base
  self.table_name = 'keepr_taxes'

  validates_presence_of :name, :value, :keepr_account_id
  validates_numericality_of :value

  belongs_to :keepr_account, :class_name => 'Keepr::Account'

  validate do |tax|
    tax.errors.add(:keepr_account, 'circular reference') if tax.keepr_account.try(:keepr_tax) == tax
  end
end
