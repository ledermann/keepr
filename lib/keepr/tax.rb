class Keepr::Tax < ActiveRecord::Base
  self.table_name = 'keepr_taxes'

  validates_presence_of :name, :value, :keepr_account_id
  validates_numericality_of :value

  belongs_to :keepr_account, :class_name => 'Keepr::Account'
  has_many :keepr_accounts, :class_name => 'Keepr::Account', :foreign_key => 'keepr_tax_id'

  validate do |tax|
    tax.errors.add(:keepr_account_id, 'circular reference') if tax.keepr_account.try(:keepr_tax) == tax
  end
end
