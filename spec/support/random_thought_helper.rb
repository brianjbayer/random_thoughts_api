# frozen_string_literal: true

module RandomThoughtHelper
  def build_random_thought_body(random_thought)
    {
      random_thought: {
        thought: random_thought.thought,
        name: random_thought.name
      }
    }
  end
end
