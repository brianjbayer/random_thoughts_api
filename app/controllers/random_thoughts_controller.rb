# frozen_string_literal: true

# Implements CRUD operations for RandomThought
class RandomThoughtsController < ApplicationController
  include RenderResponseConcern

  before_action :find_random_thought, only: %i[show update destroy]

  def index
    @random_thoughts = RandomThought.page(params[:page])
  end

  def show
    # before_action and show view
  end

  def create
    @random_thought = RandomThought.create!(random_thought_params)
    render_show_response(:created)
  end

  def update
    @random_thought.update!(random_thought_params)
    render_show_response(:ok)
  end

  def destroy
    @random_thought.destroy!
    render_show_response(:ok)
  end

  private

  def random_thought_params
    params.required(:random_thought).permit(:thought, :name)
  end

  def find_random_thought
    @random_thought = RandomThought.find(params[:id])
  end
end
