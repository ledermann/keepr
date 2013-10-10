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

  def balance
    @balance ||= keepr_postings.sum(:amount) * sign_factor
  end

  def to_s
    "#{number} (#{name})"
  end

  def update_cache_columns!
    total = self.keepr_postings.select("COUNT(*) AS postings_count, SUM(amount) AS postings_sum").first

    self.update_attributes! :keepr_postings_count      => total[:postings_count],
                            :keepr_postings_sum_amount => total[:postings_sum]
  end

private
  def sign_factor
    %w(Asset Expense).include?(kind) ? 1 : -1
  end
end
