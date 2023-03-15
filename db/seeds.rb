# frozen_string_literal: true

# Create the two users, one with a random thought
first_user = User.create!(email: 'qhound@thisisfine.com', display_name: 'Question Hound',
                          password: 'password', password_confirmation: 'password')

User.create!(email: 'user@example.com', display_name: 'Ann User',
             password: 'password', password_confirmation: 'password')

RandomThought.create!(thought: 'This is fine', name: 'Question Hound', user: first_user)
