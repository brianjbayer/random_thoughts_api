# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    display_name { Faker::Name.name }
    passwd = Faker::Internet.password
    password { passwd }
    password_confirmation { passwd }

    trait :empty_email do
      email { '' }
    end

    trait :empty_display_name do
      display_name { '' }
    end

    trait :empty_password do
      password { '' }
    end

    trait :empty_password_confirmation do
      password { '' }
    end

    trait :empty do
      empty_email
      empty_display_name
      empty_password
      empty_password_confirmation
    end
  end
end
