FactoryGirl.define do
  factory :account, class: Keepr::Account do
    number 1000
    kind :asset
    name 'Foo'
  end
end
