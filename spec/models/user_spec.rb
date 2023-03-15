# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'database constraints' do
    describe 'email' do
      it 'raises db error when email length greater than 254 characters' do
        user = build(:user, :email_255_chars)
        expect { user.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid, /PG::CheckViolation/)
      end
    end
  end

  describe 'relationships' do
    it { is_expected.to have_many(:random_thoughts).dependent(:destroy) }
  end

  describe 'validations' do
    describe 'email' do
      let(:valid_but_rejected_email) { '"Some spaces! And @ sign too!" @some.server.com' }
      let(:invalid_emails) do
        %w[user@example,com user_at_foo.org user.name@example.
           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      end

      it { is_expected.to validate_presence_of(:email) }

      it { is_expected.to validate_length_of(:email).is_at_most(254) }

      # Note that since emails are stored as case-insensitive
      # in the database, can not use the validate_uniqueness_of
      # shoulda matcher as it validates case-sensitivity
      # rubocop:disable RSpec/MultipleExpectations
      it 'is expected to validate that :email is case-insenitive unique' do
        downcase_email = Faker::Internet.email.downcase
        user = create(:user, email: downcase_email)
        new_user = build(:user, email: user.email.upcase)
        # Although there are two expectations, this is a single
        # logical assertion (and valid? must be called
        # to get errors)
        expect(new_user.valid?).to be(false)
        expect(new_user.errors.full_messages).to include('Email has already been taken')
      end
      # rubocop:enable RSpec/MultipleExpectations

      # Test email format validation with positive and negative cases
      it { is_expected.to allow_value(Faker::Internet.email).for(:email) }
      it { is_expected.not_to allow_values(invalid_emails, valid_but_rejected_email).for(:email) }
    end

    describe 'display_name' do
      it { is_expected.to validate_presence_of(:display_name) }
    end

    describe 'password' do
      # Note that has_secure_password validates presence of password
      it { is_expected.to have_secure_password }
      it { is_expected.to validate_length_of(:password).is_at_least(User::PASSWORD_MIN_LENGTH) }
    end

    describe 'authorization_min' do
      it { is_expected.to validate_presence_of(:authorization_min) }
      it { is_expected.to validate_numericality_of(:authorization_min).only_integer }
    end
  end

  describe 'methods' do
    subject(:user) { create(:user) }

    describe 'auth_revoked?' do
      it 'returns true when authorization_min > value' do
        user.authorization_min = Faker::Number.number
        expect(user.auth_revoked?(user.authorization_min - 1)).to be(true)
      end

      it 'returns false when authorization_min = value' do
        user.authorization_min = Faker::Number.number
        expect(user.auth_revoked?(user.authorization_min)).to be(false)
      end

      it 'returns false when authorization_min < value' do
        user.authorization_min = Faker::Number.number
        expect(user.auth_revoked?(user.authorization_min + 1)).to be(false)
      end
    end

    describe 'revoke_auth' do
      it 'increments authorization_min by 1' do
        initial_value = user.authorization_min
        user.revoke_auth
        expect(user.reload.authorization_min).to eql(initial_value + 1)
      end
    end
  end
end
