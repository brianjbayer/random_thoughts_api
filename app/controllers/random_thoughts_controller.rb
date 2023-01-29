# frozen_string_literal: true

# Implements CRUD operations for RandomThought
class RandomThoughtsController < ApplicationController
  def show
    @random_thought = RandomThought.find(params[:id])
    render_random_thought(200)
  end

  def create
    @random_thought = RandomThought.create!(random_thought_params)
    render_random_thought(201)
  end

  private

  def random_thought_params
    params.required(:random_thought).permit(:thought, :name)
  end

  def render_random_thought(status)
    render json: @random_thought, only: %i[id thought name], status:
  end
end
