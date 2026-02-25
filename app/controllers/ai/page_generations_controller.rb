# frozen_string_literal: true

module AI
  class PageGenerationsController < ApplicationController
    before_action :require_login
    before_action :set_child_profile
    before_action :set_book
    before_action :set_story_generation
    before_action :set_page_generation

    def show
      # Display the generated page with editable content
    end

    def update
      if @page_generation.update(page_generation_params)
        redirect_to ai_child_profile_book_story_generation_path(@child_profile, @book, @story_generation),
                    notice: "Page updated successfully."
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_child_profile
      @child_profile = current_user.family_account.child_profiles.find(params[:child_profile_id])
    end

    def set_book
      @book = @child_profile.books.find(params[:book_id])
    end

    def set_story_generation
      @story_generation = @book.story_generations.find(params[:story_generation_id])
    end

    def set_page_generation
      @page_generation = @story_generation.page_generations.find(params[:id])
    end

    def page_generation_params
      params.require(:page_generation).permit(:narration_text, dialogue_data: {})
    end
  end
end
