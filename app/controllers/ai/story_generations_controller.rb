# frozen_string_literal: true

module AI
  class StoryGenerationsController < ApplicationController
    before_action :require_login
    before_action :set_child_profile
    before_action :set_book
    before_action :set_story_generation, only: [ :show ]

    def new
      @story_generation = @book.story_generations.new
    end

    def create
      service = StoryGenerationService.new(
        book: @book,
        user_prompt: story_generation_params[:story_prompt]
      )

      @story_generation = service.call

      # Update book with story prompt
      @book.update(story_prompt: story_generation_params[:story_prompt])

      redirect_to ai_child_profile_book_story_generation_path(@child_profile, @book, @story_generation),
                  notice: "Story generation started! This may take a few minutes."
    rescue StoryGenerationService::ValidationError => e
      @story_generation = @book.story_generations.new
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    end

    def show
      @page_generations = @story_generation.page_generations.ordered
    end

    private

    def set_child_profile
      @child_profile = current_user.family_account.child_profiles.find(params[:child_profile_id])
    end

    def set_book
      @book = @child_profile.books.find(params[:book_id])
    end

    def set_story_generation
      @story_generation = @book.story_generations.find(params[:id])
    end

    def story_generation_params
      params.require(:story_generation).permit(:story_prompt, :preferred_style)
    end
  end
end
