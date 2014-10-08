class Keepr::Posting < ActiveRecord::Base
  self.table_name = 'keepr_postings'

  validates_presence_of :keepr_account_id, :amount
  validate :cost_center_validation

  belongs_to :keepr_account, :class_name => 'Keepr::Account'
  belongs_to :keepr_journal, :class_name => 'Keepr::Journal'
  belongs_to :keepr_cost_center, :class_name => 'Keepr::CostCenter'

  SIDE_DEBIT  = 'debit'
  SIDE_CREDIT = 'credit'

  after_destroy :update_account_cache_columns
  after_save :update_account_cache_columns

  scope :debits,  -> { where('amount >= 0') }
  scope :credits, -> { where('amount < 0') }

  def side=(value)
    @side = value

    if credit?
      write_attribute(:amount, -amount) if amount
    elsif debit?
      write_attribute(:amount,  amount) if amount
    else
      raise ArgumentError
    end
  end

  def side
    @side || begin
      (raw_amount < 0 ? SIDE_CREDIT : SIDE_DEBIT) if raw_amount
    end
  end

  def debit?
    side == SIDE_DEBIT
  end

  def credit?
    side == SIDE_CREDIT
  end

  def raw_amount
    read_attribute(:amount)
  end

  def amount
    raw_amount.try(:abs)
  end

  def amount=(value)
    raise ArgumentError.new('Negative amount not allowed!') if value.to_f < 0
    @side ||= SIDE_DEBIT

    write_attribute(:amount, value)
  end

private
  def update_account_cache_columns
    if keepr_account_id_changed? && keepr_account_id_was
      if previous_account = Keepr::Account.find(keepr_account_id_was)
        previous_account.update_cache_columns!
      end
    end

    keepr_account.update_cache_columns!
  end

  def cost_center_validation
    if keepr_cost_center
      unless keepr_account.profit_and_loss?
        errors.add(:keepr_cost_center_id, 'allowed for expense or revenue accounts only')
      end
    end
  end
end
