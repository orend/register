FactoryGirl.define do

  sequence :username do |n|
    "user_#{n}"
  end

  factory :user do
    username { FactoryGirl.generate(:username) }
  end
end