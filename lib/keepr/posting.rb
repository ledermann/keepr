class Keepr::Posting < ActiveRecord::Base
  self.table_name = 'keepr_postings'

  validates_presence_of :keepr_account_id, :amount

  belongs_to :keepr_account, :class_name => 'Keepr::Account'
  belongs_to :keepr_journal, :class_name => 'Keepr::Journal'

  attr_reader :kind

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

  def debit?
    kind == 'debit'
  end

  def credit?
    kind == 'credit'
  end

  def amount
    read_attribute(:amount).try(:abs)
  end

  def amount=(value)
    raise ArgumentError unless value.to_f > 0
    @kind ||= 'debit'

    write_attribute(:amount, value)
  end
end
