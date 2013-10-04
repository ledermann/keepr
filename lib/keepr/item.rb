class Keepr::Item < ActiveRecord::Base
  self.table_name = 'keepr_items'

  validates_presence_of :keepr_account_id, :amount

  belongs_to :account, :foreign_key => 'keepr_account_id'
  belongs_to :transaction, :foreign_key => 'keepr_transaction_id'
  belongs_to :accountable, :polymorphic => true

  def accountable_to_s
    [ accountable_type, accountable_id ].compact.join('/')
  end

  def credit?
    amount > 0
  end

  def debit?
    amount < 0
  end

  # def debit?
  #   return unless account
  #
  #   case account.kind
  #     when 'Revenue'    then amount < 0
  #     when 'Capital'    then amount < 0
  #     when 'Liability'  then amount < 0
  #
  #     when 'Expense'    then amount > 0
  #     when 'Asset'      then amount > 0
  #     when 'Neutral'    then amount > 0
  #   end
  # end
  #
  # def credit?
  #   return unless account
  #
  #   !debit?
  # end
end
