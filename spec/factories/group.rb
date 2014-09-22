FactoryGirl.define do
  factory :group, class: Keepr::Group do
    target 'Asset'
    name 'Foo'
  end
end
