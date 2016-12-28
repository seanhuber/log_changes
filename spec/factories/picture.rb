FactoryGirl.define do
  factory :picture do
    name 'something_amazing.png'
    association :imageable, factory: :product
  end
end
