# frozen_string_literal: true

module RandomThoughtHelper
  def build_random_thought_body(random_thought)
    body = random_thought.attributes.slice('thought', 'name', 'mood')
    { random_thought: body }
  end
end
