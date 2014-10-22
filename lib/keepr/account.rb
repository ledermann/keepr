class Keepr::Account < ActiveRecord::Base
  self.table_name = 'keepr_accounts'

  has_ancestry :orphan_strategy => :restrict

  enum :kind => [ :asset, :liability, :revenue, :expense, :neutral ]

  validates_presence_of :number, :name
  validates_uniqueness_of :number
  validate :group_validation
  validate :tax_validation

  has_many :keepr_postings, :class_name => 'Keepr::Posting', :foreign_key => 'keepr_account_id', :dependent => :restrict_with_error
  has_many :keepr_taxes, :class_name => 'Keepr::Tax', :foreign_key => 'keepr_account_id', :dependent => :restrict_with_error

  belongs_to :keepr_tax, :class_name => 'Keepr::Tax'
  belongs_to :keepr_group, :class_name => 'Keepr::Group'
  belongs_to :accountable, :polymorphic => true

  default_scope { order(:number) }

  def self.with_sums(date=nil)
    scope = select('keepr_accounts.*, SUM(amount) AS sum_amount').
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

  def self.merged_with_sums(date=nil)
    accounts = with_sums(date).to_a

    # Sum up child accounts to parent
    position = 0
    while account = accounts[position] do
      if account.parent_id
        if parent_account = accounts.find { |a| a.id == account.parent_id }
          parent_account.sum_amount ||= 0
          parent_account.sum_amount += account.sum_amount
          accounts.delete_at(position)
        else
          raise
        end
      else
        position += 1
      end
    end

    accounts
  end

  def profit_and_loss?
    revenue? || expense?
  end

  def keepr_postings
    Keepr::Posting.
      joins(:keepr_account).
      where(subtree_conditions)
  end

  def balance(date=nil)
    if date
      if date.is_a?(Date)
        keepr_postings.joins(:keepr_journal).where("keepr_journals.date <= '#{date.to_s(:db)}'").sum(:amount)
      elsif date.is_a?(Range)
        keepr_postings.joins(:keepr_journal).where("keepr_journals.date BETWEEN '#{date.first.to_s(:db)}' AND '#{date.last.to_s(:db)}'").sum(:amount)
      else
        raise ArgumentError
      end
    else
      keepr_postings.sum(:amount)
    end
  end

  def number_as_string
    if number < 1000
      "%04d" % number
    else
      number.to_s
    end
  end

  def to_s
    "#{number_as_string} (#{name})"
  end

private
  def group_validation
    if keepr_group.present?
      if asset?
        errors.add(:kind, 'does match group') unless keepr_group.asset?
      elsif liability?
        errors.add(:kind, 'does match group') unless keepr_group.liability?
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
