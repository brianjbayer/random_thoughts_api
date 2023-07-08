# frozen_string_literal: true

FactoryBot.define do
  factory :random_thought do
    user

    thought { Faker::Lorem.sentence }
    mood { Faker::Lorem.sentence }

    trait :empty_thought do
      thought { '' }
    end

    trait :empty_mood do
      mood { '' }
    end

    trait :empty do
      empty_thought
      empty_mood
    end
  end
end
