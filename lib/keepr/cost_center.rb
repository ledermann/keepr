class Keepr::CostCenter < ActiveRecord::Base
  self.table_name = 'keepr_cost_centers'

  validates_presence_of :number, :name
  validates_uniqueness_of :number

  has_many :keepr_postings, class_name: 'Keepr::Posting', foreign_key: 'keepr_cost_center_id', dependent: :restrict_with_error
end
