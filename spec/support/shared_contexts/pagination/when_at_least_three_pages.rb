# frozen_string_literal: true

RSpec.shared_context 'when at least three pages' do |class_under_test, factory_name|
  let(:pages) { 3 }
  let(:per_page) { class_under_test.page.limit_value }
  let(:num_items) { (per_page * (pages - 1)) + 1 }

  before do
    create_list(factory_name, num_items)
  end
end
