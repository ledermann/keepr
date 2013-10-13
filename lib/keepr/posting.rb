class Keepr::Posting < ActiveRecord::Base
  self.table_name = 'keepr_postings'

  validates_presence_of :keepr_account_id, :amount

  belongs_to :keepr_account, :class_name => 'Keepr::Account'
  belongs_to :keepr_journal, :class_name => 'Keepr::Journal'

  SIDE_DEBIT  = 'debit'
  SIDE_CREDIT = 'credit'

  def side=(value)
    @side = value

    if credit?
      write_attribute(:amount, -amount)
    elsif debit?
      write_attribute(:amount,  amount)
    else
      raise ArgumentError
    end
  end

  def side
    @side || begin
      raw_amount = read_attribute(:amount)
      (raw_amount < 0 ? SIDE_CREDIT : SIDE_DEBIT) if raw_amount
    end
  end

  def debit?
    side == SIDE_DEBIT
  end

  def credit?
    side == SIDE_CREDIT
  end

  def amount
    read_attribute(:amount).try(:abs)
  end

  def amount=(value)
    raise ArgumentError unless value.to_f > 0
    @side ||= SIDE_DEBIT

    write_attribute(:amount, value)
  end
end
