# frozen_string_literal: true

json.data @random_thoughts, partial: 'random_thought', as: :random_thought

json.meta do
  json.current_page @random_thoughts.current_page
  json.next_page @random_thoughts.next_page
  json.prev_page @random_thoughts.prev_page
  json.total_pages @random_thoughts.total_pages
  json.total_count RandomThought.count
end
