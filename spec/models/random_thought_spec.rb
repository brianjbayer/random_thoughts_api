# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RandomThought do
  describe 'default scope' do
    it 'returns most recent first' do
      create_list(:random_thought, 20)
      most_recent = create(:random_thought)
      expect(described_class.first).to eql(most_recent)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:thought) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
