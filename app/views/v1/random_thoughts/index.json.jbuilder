# frozen_string_literal: true

json.data @random_thoughts, partial: 'random_thought', as: :random_thought

json.partial! 'v1/meta/meta', items: @random_thoughts, total: @random_thoughts_total
