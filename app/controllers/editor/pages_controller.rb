module Editor
  class PagesController < ApplicationController
    before_action :require_login
    before_action :set_child_profile
    before_action :set_book
    before_action :authorize_editor_access
    before_action :set_page, only: [ :update, :destroy ]

    def create
      # Check onboarding book page limit
      if @book.is_onboarding_book && @book.drawings.count >= 5
        redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                    alert: "Onboarding books are limited to 5 pages."
        return
      end

      @page = @book.drawings.new(page_create_params)

      if @page.save
        @book.update_last_edited!
        redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                    notice: "Page added successfully."
      else
        redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                    alert: "Failed to add page: #{@page.errors.full_messages.join(', ')}"
      end
    end

    def update
      if @page.update(page_update_params)
        @book.update_last_edited!
        respond_to do |format|
          format.html do
            redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                        notice: "Page updated successfully."
          end
          format.json do
            render json: {
              status: "saved",
              page_id: @page.id,
              updated_at: @page.updated_at.iso8601
            }
          end
        end
      else
        respond_to do |format|
          format.html do
            redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                        alert: "Failed to update page."
          end
          format.json do
            render json: {
              status: "error",
              errors: @page.errors.full_messages
            }, status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @page.destroy
      @book.update_last_edited!
      redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                  notice: "Page deleted successfully."
    end

    private

    def set_child_profile
      @child_profile = ChildProfile.find(params[:child_profile_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to dashboard_path, alert: "Child profile not found."
    end

    def set_book
      @book = @child_profile.books.find(params[:book_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to child_profile_books_path(@child_profile), alert: "Book not found."
    end

    def set_page
      @page = @book.drawings.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                  alert: "Page not found."
    end

    def authorize_editor_access
      unless @book.editable_by?(current_user)
        redirect_to child_profile_book_path(@child_profile, @book),
                    alert: "You don't have permission to edit this book."
      end
    end

    def page_create_params
      # For blank pages, we don't require an image immediately
      params.permit(:image, :narration_text, :dialogue_text, :is_cover)
    end

    def page_update_params
      params.require(:page).permit(:narration_text, :dialogue_text, :caption)
    end
  end
end
