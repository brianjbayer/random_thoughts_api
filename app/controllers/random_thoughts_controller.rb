# frozen_string_literal: true

# Implements CRUD operations for RandomThought
class RandomThoughtsController < ApplicationController
  def index
    @random_thoughts = RandomThought.page(params[:page])
  end

  def show
    @random_thought = RandomThought.find(params[:id])
  end

  def create
    @random_thought = RandomThought.create!(random_thought_params)
    # FYI: render 'show' renders random_thoughts/show.json.jbuilder
    render 'show', status: :created
  end

  private

  def random_thought_params
    params.required(:random_thought).permit(:thought, :name)
  end
end
