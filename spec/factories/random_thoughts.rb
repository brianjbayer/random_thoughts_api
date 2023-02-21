# frozen_string_literal: true

FactoryBot.define do
  factory :random_thought do
    thought { Faker::Lorem.sentence }
    name { Faker::Name.name }

    trait :empty_thought do
      thought { '' }
    end

    trait :empty_name do
      name { '' }
    end

    trait :empty do
      empty_thought
      empty_name
    end
  end
end
