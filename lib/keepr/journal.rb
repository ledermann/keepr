class Keepr::Journal < ActiveRecord::Base
  self.table_name = 'keepr_journals'

  validates_presence_of :date
  validates_uniqueness_of :number, :allow_blank => true

  has_many :keepr_postings, -> { order(:amount => :desc) },
           :class_name => 'Keepr::Posting', :foreign_key => 'keepr_journal_id', :dependent => :destroy

  belongs_to :accountable, :polymorphic => true

  accepts_nested_attributes_for :keepr_postings, :allow_destroy => true, :reject_if => :all_blank

  default_scope { order({:date => :desc}, {:id => :desc}) }

  validate :validate_postings

  def credit_postings
    existing_postings.select(&:credit?)
  end

  def debit_postings
    existing_postings.select(&:debit?)
  end

  def amount
    debit_postings.sum(&:amount)
  end

  after_initialize :set_defaults
  before_update :check_permanent
  before_destroy :check_permanent

private
  def existing_postings
    keepr_postings.to_a.delete_if(&:marked_for_destruction?)
  end

  def set_defaults
    self.date ||= Date.today
  end

  def validate_postings
    if existing_postings.map(&:keepr_account_id).uniq.length < 2
      # At least two accounts have to be booked
      errors.add :base, :account_missing
    elsif existing_postings.select(&:debit?).count > 1 && existing_postings.select(&:credit?).count > 1
      # A split is allowed either on debit or credit, not both
      errors.add :base, :split_on_both_sides
    elsif existing_postings.map(&:raw_amount).compact.sum != 0
      # Debit does not match credit
      errors.add :base, :amount_mismatch
    end
  end

  def check_permanent
    if self.permanent_was
      # If marked as permanent, no changes are allowed
      errors.add :base, :changes_not_allowed

      if ActiveRecord::VERSION::MAJOR < 5
        false
      else
        throw :abort
      end
    end
  end
end
