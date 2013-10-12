class Keepr::Posting < ActiveRecord::Base
  self.table_name = 'keepr_postings'

  validates_presence_of :keepr_account_id, :amount

  belongs_to :keepr_account, :class_name => 'Keepr::Account'
  belongs_to :keepr_journal, :class_name => 'Keepr::Journal'

  KIND_DEBIT  = 'debit'
  KIND_CREDIT = 'credit'

  def kind=(value)
    @kind = value

    if credit?
      write_attribute(:amount, -amount)
    elsif debit?
      write_attribute(:amount,  amount)
    else
      raise ArgumentError
    end
  end

  def kind
    @kind || (read_attribute(:amount) < 0 ? KIND_CREDIT : KIND_DEBIT)
  end

  def debit?
    kind == KIND_DEBIT
  end

  def credit?
    kind == KIND_CREDIT
  end

  def amount
    read_attribute(:amount).try(:abs)
  end

  def amount=(value)
    raise ArgumentError unless value.to_f > 0
    @kind ||= KIND_DEBIT

    write_attribute(:amount, value)
  end
end
