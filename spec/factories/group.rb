# frozen_string_literal: true

FactoryBot.define do
  factory :group, class: Keepr::Group do
    target { :asset }
    name { 'Foo' }
  end
end
