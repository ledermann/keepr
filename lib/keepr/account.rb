class Keepr::Account < ActiveRecord::Base
  self.table_name = 'keepr_accounts'

  has_ancestry orphan_strategy: :restrict

  enum kind: [ :asset, :liability, :revenue, :expense, :neutral, :debtor, :creditor ]

  validates_presence_of :number, :name
  validates_uniqueness_of :number
  validate :group_validation
  validate :tax_validation

  has_many :keepr_postings, class_name: 'Keepr::Posting', foreign_key: 'keepr_account_id', dependent: :restrict_with_error
  has_many :keepr_taxes, class_name: 'Keepr::Tax', foreign_key: 'keepr_account_id', dependent: :restrict_with_error

  belongs_to :keepr_tax, class_name: 'Keepr::Tax'
  belongs_to :keepr_group, class_name: 'Keepr::Group'
  belongs_to :accountable, polymorphic: true

  default_scope { order(:number) }

  def self.with_sums(options={})
    raise ArgumentError unless options.is_a?(Hash)

    subquery = Keepr::Posting.
                 select('SUM(keepr_postings.amount)').
                 joins(:keepr_journal).
                 where('keepr_postings.keepr_account_id = keepr_accounts.id')

    date           = options[:date]
    permanent_only = options[:permanent_only]

    if date
      if date.is_a?(Date)
        subquery = subquery.where "keepr_journals.date <= '#{date.to_s(:db)}'"
      elsif date.is_a?(Range)
        subquery = subquery.where "keepr_journals.date BETWEEN '#{date.first.to_s(:db)}' AND '#{date.last.to_s(:db)}'"
      else
        raise ArgumentError
      end
    end

    if permanent_only
      subquery = subquery.where "keepr_journals.permanent = #{connection.quoted_true}"
    end

    select "keepr_accounts.*, (#{subquery.to_sql}) AS sum_amount"
  end

  def self.merged_with_sums(options={})
    accounts = with_sums(options).to_a

    # Sum up child accounts to parent
    position = 0
    while account = accounts[position] do
      if account.parent_id && account.sum_amount
        if parent_account = accounts.find { |a| a.id == account.parent_id }
          parent_account.sum_amount ||= 0
          parent_account.sum_amount += account.sum_amount
          accounts.delete_at(position)
        else
          raise RuntimeError
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
        errors.add(:kind, :group_mismatch) unless keepr_group.asset?
      elsif liability?
        errors.add(:kind, :group_mismatch) unless keepr_group.liability?
      elsif profit_and_loss?
        errors.add(:kind, :group_mismatch) unless keepr_group.profit_and_loss?
      else
        errors.add(:kind, :group_conflict)
      end

      errors.add(:keepr_group_id, :no_group_allowed_for_result) if keepr_group.is_result
    end
  end

  def tax_validation
    errors.add(:keepr_tax_id, :circular_reference) if keepr_tax && keepr_tax.keepr_account == self
  end
end
