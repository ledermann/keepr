# frozen_string_literal: true

class Keepr::Posting < ActiveRecord::Base
  self.table_name = 'keepr_postings'

  validates_presence_of :keepr_account_id, :amount
  validate :cost_center_validation

  belongs_to :keepr_account, class_name: 'Keepr::Account'
  belongs_to :keepr_journal, class_name: 'Keepr::Journal'
  belongs_to :keepr_cost_center, class_name: 'Keepr::CostCenter'
  belongs_to :accountable, polymorphic: true

  SIDE_DEBIT  = 'debit'
  SIDE_CREDIT = 'credit'

  scope :debits,  -> { where('amount >= 0') }
  scope :credits, -> { where('amount < 0') }

  def side
    @side || begin
      (raw_amount.negative? ? SIDE_CREDIT : SIDE_DEBIT) if raw_amount
    end
  end

  def side=(value)
    raise ArgumentError unless [SIDE_DEBIT, SIDE_CREDIT].include?(value)

    @side = value
    return unless amount

    if credit?
      self.raw_amount = -amount.to_d
    elsif debit?
      self.raw_amount =  amount.to_d
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

  def raw_amount=(value)
    write_attribute(:amount, value)
  end

  def amount
    raw_amount.try(:abs)
  end

  def amount=(value)
    @side ||= SIDE_DEBIT

    unless value
      self.raw_amount = nil
      return
    end

    raise ArgumentError, 'Negative amount not allowed!' if value.to_d.negative?

    self.raw_amount = credit? ? -value.to_d : value.to_d
  end

  private

  def cost_center_validation
    return unless keepr_cost_center
    return if keepr_account.profit_and_loss?

    # allowed for expense or revenue accounts only
    errors.add :keepr_cost_center_id, :allowed_for_expense_or_revenue_only
  end
end
