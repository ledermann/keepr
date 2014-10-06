class Keepr::CostCenter < ActiveRecord::Base
  self.table_name = 'keepr_cost_centers'

  validates_presence_of :number, :name

  has_many :keepr_postings, :class_name => 'Keepr::Posting', :foreign_key => 'keepr_cost_center_id'
end
