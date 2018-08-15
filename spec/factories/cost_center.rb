# frozen_string_literal: true

FactoryBot.define do
  factory :cost_center, class: Keepr::CostCenter do
    number 'FZ1'
    name 'Kleintransporter'
  end
end
