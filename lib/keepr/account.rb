class Keepr::Account < ActiveRecord::Base
  self.table_name = 'keepr_accounts'

  has_ancestry :orphan_strategy => :restrict

  KIND = [ 'Asset',
           'Liability',
           'Revenue',
           'Expense',
           'Neutral' ]

  validates_presence_of :number, :name
  validates_uniqueness_of :number
  validates_inclusion_of :kind, :in => KIND
  validate :group_validation
  validate :tax_validation

  has_many :keepr_postings, :class_name => 'Keepr::Posting', :foreign_key => 'keepr_account_id'
  has_many :keepr_taxes, :class_name => 'Keepr::Tax', :foreign_key => 'keepr_account_id'

  belongs_to :keepr_tax, :class_name => 'Keepr::Tax'
  belongs_to :keepr_group, :class_name => 'Keepr::Group'
  belongs_to :accountable, :polymorphic => true

  default_scope { order('number ASC') }
  scope :with_postings, -> { where('keepr_postings_count > 0') }
  scope :without_postings, -> { where('keepr_postings_count = 0') }
  scope :not_zero_balance, -> { where('keepr_postings_sum_amount <> 0.0') }

  def self.with_balance(date=nil)
    scope = select('keepr_accounts.*, SUM(amount) AS preloaded_sum_amount').
              group('keepr_accounts.id').
              joins('LEFT JOIN keepr_postings ON keepr_postings.keepr_account_id = keepr_accounts.id')

    if date
      scope = scope.joins('LEFT JOIN keepr_journals ON keepr_journals.id = keepr_postings.keepr_journal_id')

      if date.is_a?(Date)
        scope = scope.where("keepr_journals.id IS NULL OR keepr_journals.date <= '#{date.to_s(:db)}'")
      elsif date.is_a?(Range)
        scope = scope.where("keepr_journals.id IS NULL OR (keepr_journals.date BETWEEN '#{date.first.to_s(:db)}' AND '#{date.last.to_s(:db)}')")
      else
        raise ArgumentError
      end
    end

    scope
  end

  def self.merged_with_balance(date=nil)
    array = with_balance(date).to_a

    position = 0
    while account = array[position] do
      if account.parent_id
        if parent = array.find { |a| a.id == account.parent_id }
          parent.preloaded_sum_amount ||= 0
          parent.preloaded_sum_amount += account.preloaded_sum_amount
          array.delete_at(position)
        else
          raise
        end
      else
        position += 1
      end
    end

    array
  end

  def asset?
    kind == 'Asset'
  end

  def liability?
    kind == 'Liability'
  end

  def profit_and_loss?
    (kind == 'Revenue') || (kind == 'Expense')
  end

  def keepr_postings
    Keepr::Posting.
      joins(:keepr_account).
      where(subtree_conditions)
  end

  def balance(date=nil)
    if attributes['preloaded_sum_amount'].present?
      raise ArgumentError if date
      attributes['preloaded_sum_amount']
    else
      if date
        if date.is_a?(Date)
          keepr_postings.joins(:keepr_journal).where("keepr_journals.date <= '#{date.to_s(:db)}'").sum(:amount)
        elsif date.is_a?(Range)
          keepr_postings.joins(:keepr_journal).where("keepr_journals.date BETWEEN '#{date.first.to_s(:db)}' AND '#{date.last.to_s(:db)}'").sum(:amount)
        else
          raise ArgumentError
        end
      else
        keepr_postings_sum_amount
      end
    end * sign_factor
  end

  def to_s
    "#{number} (#{name})"
  end

  def update_cache_columns!
    account = self
    while account do
      total = account.keepr_postings.select('COUNT(*) AS postings_count, SUM(amount) AS postings_sum').first

      account.update_attributes! :keepr_postings_count      => total[:postings_count] || 0.0,
                                 :keepr_postings_sum_amount => total[:postings_sum] || 0.0

      account = account.parent
    end
  end

private
  def sign_factor
    %w(Asset Expense).include?(kind) ? 1 : -1
  end

  def group_validation
    if keepr_group.present?
      if asset?
        errors.add(:kind, 'does match group') unless keepr_group.asset?
      elsif liability?
        errors.add(:kind, 'does match group') unless keepr_group.liabiliy?
      elsif profit_and_loss?
        errors.add(:kind, 'does match group') unless keepr_group.profit_and_loss?
      else
        errors.add(:kind, 'conflicts with group')
      end

      errors.add(:keepr_group_id, 'is a result group') if keepr_group.is_result
    end
  end

  def tax_validation
    errors.add(:keepr_tax_id, 'circular reference') if keepr_tax && keepr_tax.keepr_account == self
  end
end
