module Editor
  class BooksController < ApplicationController
    before_action :require_login
    before_action :set_child_profile
    before_action :set_book
    before_action :authorize_editor_access

    def edit
      @drawings = @book.drawings.ordered
      @can_add_pages = !@book.is_onboarding_book || @drawings.count < 5
    end

    def update
      if @book.update(book_params)
        @book.update_last_edited!
        redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                    notice: "Book updated successfully."
      else
        @drawings = @book.drawings.ordered
        @can_add_pages = !@book.is_onboarding_book || @drawings.count < 5
        render :edit, status: :unprocessable_entity
      end
    end

    def auto_save
      if @book.update(book_params)
        @book.update_last_edited!
        render json: {
          status: "saved",
          updated_at: @book.last_edited_at.iso8601
        }
      else
        render json: {
          status: "error",
          errors: @book.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    def preview
      @drawings = @book.drawings.ordered
      render layout: "preview"
    end

    def update_cover
      if params[:remove_cover] == "true"
        @book.cover_image.purge if @book.cover_image.attached?
        @book.update_last_edited!
        redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                    notice: "Cover image removed successfully."
      elsif params[:cover_image].present?
        if @book.update(cover_image: params[:cover_image])
          @book.update_last_edited!
          redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                      notice: "Cover image updated successfully."
        else
          redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                      alert: "Failed to update cover image."
        end
      else
        redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
                    alert: "No cover image provided."
      end
    end

    private

    def set_child_profile
      @child_profile = ChildProfile.find(params[:child_profile_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to dashboard_path, alert: "Child profile not found."
    end

    def set_book
      @book = @child_profile.books.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to child_profile_books_path(@child_profile), alert: "Book not found."
    end

    def authorize_editor_access
      unless @book.editable_by?(current_user)
        redirect_to child_profile_book_path(@child_profile, @book),
                    alert: "You don't have permission to edit this book."
      end
    end

    def book_params
      params.require(:book).permit(:title, :dedication, :edit_mode)
    end
  end
end
