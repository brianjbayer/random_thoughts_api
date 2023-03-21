# frozen_string_literal: true

module V1
  # Implements CRUD operations for RandomThought
  class RandomThoughtsController < V1::ApplicationController
    before_action :authorize_request, only: %i[create update destroy]
    before_action :find_random_thought, only: %i[show update destroy]
    before_action :find_random_thought_user, :authorize_current_user, only: %i[update destroy]

    def index
      return if random_thoughts_for_name

      @random_thoughts = RandomThought.page(page)
      @random_thoughts_total = RandomThought.count
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
      params.required(:random_thought).permit(:thought, :mood)
    end

    def find_random_thought
      @random_thought = RandomThought.find(params[:id])
    end

    def find_random_thought_user
      @user = @random_thought.user
    end

    def display_name
      return false if params[:name].blank?

      params[:name]
    end

    def random_thoughts_for_name
      return false unless display_name

      random_thoughts_for_name = RandomThought.joins(:user).where(user: { display_name: })
      @random_thoughts = random_thoughts_for_name.page(page)
      @random_thoughts_total = random_thoughts_for_name.count
    end

    def page
      params[:page]
    end
  end
end
