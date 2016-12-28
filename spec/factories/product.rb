FactoryGirl.define do
  factory :product do
    name 'Unbreakable Glasses'
    association :employee
  end
end
