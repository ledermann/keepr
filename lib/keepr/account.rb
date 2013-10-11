class Keepr::Account < ActiveRecord::Base
  self.table_name = 'keepr_accounts'

  KIND = [ 'Asset',
           'Liability',
           'Revenue',
           'Expense',
           'Neutral' ]

  validates_presence_of :number, :name
  validates_uniqueness_of :number
  validates_inclusion_of :kind, :in => KIND

  has_many :keepr_postings, :class_name => 'Keepr::Posting', :foreign_key => 'keepr_account_id'
  belongs_to :accountable, :polymorphic => true

  default_scope { order('number ASC') }
  scope :with_postings, -> { where('keepr_postings_count > 0') }
  scope :without_postings, -> { where('keepr_postings_count = 0') }
  scope :not_zero_balance, -> { where('keepr_postings_sum_amount <> 0.0') }

  def self.with_balance(date=nil)
    scope = Keepr::Account.joins(:keepr_postings)

    if date
      scope = scope.joins(:keepr_postings => :keepr_journal).where("keepr_journals.date <= '#{date.to_s(:db)}'")
    end

    scope.group('keepr_accounts.id').
          select('keepr_accounts.*, SUM(keepr_postings.amount) AS preloaded_sum_amount')
  end

  def balance(date=nil)
    if attributes['preloaded_sum_amount']
      raise ArgumentError if date
      attributes['preloaded_sum_amount']
    else
      if date
        keepr_postings.joins(:keepr_journal).where("keepr_journals.date <= '#{date.to_s(:db)}'").sum(:amount)
      else
        keepr_postings_sum_amount
      end
    end * sign_factor
  end

  def to_s
    "#{number} (#{name})"
  end

  def update_cache_columns!
    total = self.keepr_postings.select("COUNT(*) AS postings_count, SUM(amount) AS postings_sum").first

    self.update_attributes! :keepr_postings_count      => total[:postings_count] || 0.0,
                            :keepr_postings_sum_amount => total[:postings_sum] || 0.0
  end

private
  def sign_factor
    %w(Asset Expense).include?(kind) ? 1 : -1
  end
end
