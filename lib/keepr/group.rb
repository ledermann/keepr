class Keepr::Group < ActiveRecord::Base
  self.table_name = 'keepr_groups'

  has_ancestry :orphan_strategy => :restrict

  TARGET = [ 'Asset', 'Liability', 'Profit & Loss' ]

  validates_presence_of :name
  validates_inclusion_of :target, :in => TARGET

  has_many :keepr_accounts, :class_name => 'Keepr::Account', :foreign_key => 'keepr_group_id', :dependent => :restrict_with_error

  before_validation :get_from_parent

  scope :asset,           -> { where(:target => 'Asset') }
  scope :liability,       -> { where(:target => 'Liability') }
  scope :profit_and_loss, -> { where(:target => 'Profit & Loss') }

  def self.result
    where(:is_result => true).first
  end

  def asset?
    target == 'Asset'
  end

  def liability?
    target == 'Liability'
  end

  def profit_and_loss?
    target == 'Profit & Loss'
  end

private
  def get_from_parent
    if self.parent
      self.target = self.parent.target
    end
  end
end
