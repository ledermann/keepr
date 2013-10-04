class Keepr::Item < ActiveRecord::Base
  self.table_name = 'keepr_items'

  validates_presence_of :keepr_account_id, :amount

  belongs_to :account, :foreign_key => 'keepr_account_id'
  belongs_to :transaction, :foreign_key => 'keepr_transaction_id'
  belongs_to :accountable, :polymorphic => true

  def credit?
    amount > 0
  end

  def debit?
    amount < 0
  end
end
