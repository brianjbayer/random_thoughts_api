# frozen_string_literal: true

json.meta do
  json.current_page items.current_page
  json.next_page items.next_page
  json.prev_page items.prev_page
  json.total_pages items.total_pages
  json.total_count item_class.count
end
