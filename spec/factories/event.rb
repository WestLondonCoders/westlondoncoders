FactoryGirl.define do
  factory :event do
    name "Learn, discuss and practice code"
    description "This meetup will be cool"
    date Time.now
  end
end