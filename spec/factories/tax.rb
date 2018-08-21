# frozen_string_literal: true

FactoryBot.define do
  factory :tax, class: Keepr::Tax do
    name { 'USt19' }
    description { 'Umsatzsteuer 19%' }
    value { 19.0 }
    keepr_account { FactoryBot.create :account, number: 1776 }
  end
end
