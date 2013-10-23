class Keepr::Journal < ActiveRecord::Base
  self.table_name = 'keepr_journals'

  validates_presence_of :date

  has_many :keepr_postings, :class_name => 'Keepr::Posting', :foreign_key => 'keepr_journal_id', :dependent => :destroy
  belongs_to :accountable, :polymorphic => true

  accepts_nested_attributes_for :keepr_postings, :allow_destroy => true, :reject_if => :all_blank

  default_scope { order('date DESC, id DESC') }

  validate :validate_postings

  def credit_postings
    keepr_postings.select(&:credit?)
  end

  def debit_postings
    keepr_postings.select(&:debit?)
  end

  def amount
    credit_amount || debit_amount
  end

  after_initialize :set_defaults

private
  def set_defaults
    self.date ||= Date.today
  end

  def credit_amount
    credit_postings.sum(&:amount).abs
  end

  def debit_amount
    debit_postings.sum(&:amount).abs
  end

  def validate_postings
    if keepr_postings.length < 2
      errors.add(:base, 'At least two postings required!')
    elsif debit_amount != credit_amount
      errors.add(:base, 'Debit does not match credit!')
    end
  end
end
