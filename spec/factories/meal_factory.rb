FactoryGirl.define do
  factory :meal do
    served_at { Time.now + 7.days }
    capacity 64
    association :head_cook, factory: :user
    location
    association :host_community, factory: :community
  end
end