FactoryGirl.define do
  factory :account, class: Keepr::Account do
    number 1000
    kind 'Asset'
    name 'Foo'
  end
end
