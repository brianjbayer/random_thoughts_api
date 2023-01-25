# frozen_string_literal: true

# Implements CRUD operations for RandomThought
class RandomThoughtsController < ApplicationController
  def show
    @random_thought = RandomThought.find(params[:id])
    render json: @random_thought, only: %i[id thought name]
  end
end
