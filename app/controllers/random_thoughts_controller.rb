# frozen_string_literal: true

# Implements CRUD operations for RandomThought
class RandomThoughtsController < ApplicationController
  before_action :authorize_request, only: %i[create update destroy]
  before_action :find_random_thought, only: %i[show update destroy]
  before_action :find_random_thought_user, only: %i[update destroy]
  before_action :authorize_current_user, only: %i[update destroy]

  def index
    @random_thoughts = RandomThought.page(params[:page])
  end

  def show
    # before_action and show view
  end

  def create
    @random_thought = @current_user.random_thoughts.build(random_thought_params)
    if @random_thought.save
      render_show_response(:created)
    else
      # NOTE: Bad Requests are handled by error handler
      render_validation_error_response(@random_thought)
    end
  end

  def update
    if @random_thought.update(random_thought_params)
      render_show_response(:ok)
    else
      # NOTE: Bad Requests are handled by error handler
      render_validation_error_response(@random_thought)
    end
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

  def find_random_thought_user
    @user = @random_thought.user
  end
end
