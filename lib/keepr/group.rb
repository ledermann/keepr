# frozen_string_literal: true

class Keepr::Group < ActiveRecord::Base
  self.table_name = 'keepr_groups'

  has_ancestry orphan_strategy: :restrict

  if ActiveRecord.version >= Gem::Version.new('7.1')
    enum :target, %i[asset liability profit_and_loss]
  else
    enum target: %i[asset liability profit_and_loss]
  end

  validates_presence_of :name

  has_many :keepr_accounts, class_name: 'Keepr::Account', foreign_key: 'keepr_group_id', dependent: :restrict_with_error

  before_validation :set_target_from_parent

  validate :check_result_and_target

  def self.result
    where(is_result: true).first
  end

  def keepr_postings
    if is_result
      Keepr::Posting
        .joins(:keepr_account)
        .where(keepr_accounts: { kind: [
                 Keepr::Account.kinds[:revenue],
                 Keepr::Account.kinds[:expense]
               ] })
    else
      Keepr::Posting
        .joins(keepr_account: :keepr_group)
        .merge(subtree)
    end
  end

  private

  def set_target_from_parent
    self.class.unscoped do
      self.target = parent.target if parent
    end
  end

  def check_result_and_target
    return unless is_result

    # Attribute `is_result` allowed for liability target only
    errors.add :base, :liability_needed_for_result unless liability?
  end
end
