# frozen_string_literal: true

# Implements CRUD operations for RandomThought
class RandomThoughtsController < ApplicationController
  before_action :find_random_thought, only: %i[show update]

  def index
    @random_thoughts = RandomThought.page(params[:page])
  end

  def show
    # before_action and show view
  end

  def create
    @random_thought = RandomThought.create!(random_thought_params)
    # FYI: render 'show' renders random_thoughts/show.json.jbuilder
    render 'show', status: :created
  end

  def update
    @random_thought.update(random_thought_params)
    render 'show', status: :ok
  end

  private

  def random_thought_params
    params.required(:random_thought).permit(:thought, :name)
  end

  def find_random_thought
    @random_thought = RandomThought.find(params[:id])
  end
end
