class Keepr::Transaction < ActiveRecord::Base
  self.table_name = 'keepr_transactions'

  validates_presence_of :date

  has_many :items, :foreign_key => 'keepr_transaction_id', :dependent => :delete_all
  belongs_to :accountable, :polymorphic => true

  accepts_nested_attributes_for :items, :allow_destroy => true, :reject_if => :all_blank

  default_scope { order('date ASC, id ASC') }

  validate :validate_items

  def credit_items
    items.select(&:credit?)
  end

  def debit_items
    items.select(&:debit?)
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
    credit_items.sum(&:amount).abs
  end

  def debit_amount
    debit_items.sum(&:amount).abs
  end

  def validate_items
    if items.length < 2
      errors.add(:base, 'At least two items required!')
    elsif debit_amount != credit_amount
      errors.add(:base, 'Debit does not match credit!')
    end
  end
end
