class Keepr::Posting < ActiveRecord::Base
  self.table_name = 'keepr_postings'

  validates_presence_of :keepr_account_id, :amount

  belongs_to :account, :foreign_key => 'keepr_account_id'
  belongs_to :journal, :foreign_key => 'keepr_journal_id'

  def credit?
    amount < 0
  end

  def debit?
    amount > 0
  end
end
