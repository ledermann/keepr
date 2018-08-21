# frozen_string_literal: true

FactoryBot.define do
  factory :account, class: Keepr::Account do
    number { 12_345 }
    kind { :asset }
    name { 'Foo' }
  end
end
