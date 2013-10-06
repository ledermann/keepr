class Keepr::Account < ActiveRecord::Base
  self.table_name = 'keepr_accounts'

  KIND = [ 'Asset',
           'Liability',
           'Equity',
           'Revenue',
           'Expense',
           'Neutral' ]

  validates_presence_of :number, :name
  validates_uniqueness_of :number
  validates_inclusion_of :kind, :in => KIND

  has_many :items, :foreign_key => 'keepr_account_id'
  belongs_to :accountable, :polymorphic => true

  default_scope { order('number ASC') }

  def balance
    @balance ||= items.sum(:amount) * sign_factor
  end

  def to_s
    "#{number} (#{name})"
  end

private
  def sign_factor
    %w(Asset Equity Expense).include?(kind) ? 1 : -1
  end
end
