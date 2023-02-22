# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
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
  end
end
