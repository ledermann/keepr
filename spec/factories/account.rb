FactoryGirl.define do
  factory :account, class: Keepr::Account do
    number 12345
    kind :asset
    name 'Foo'
  end
end
