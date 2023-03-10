# frozen_string_literal: true

json.data @random_thoughts, partial: 'random_thought', as: :random_thought

json.partial! 'meta/meta', items: @random_thoughts, item_class: RandomThought
