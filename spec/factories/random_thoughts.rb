# frozen_string_literal: true

FactoryBot.define do
  factory :random_thought do
    thought { Faker::Lorem.sentence }
    name { Faker::Name.name }
  end
end
