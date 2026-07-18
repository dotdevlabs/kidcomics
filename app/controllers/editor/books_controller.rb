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
                    notice: t("flash.editor.books.updated")
      else
        @drawings = @book.drawings.ordered
        @can_add_pages = !@book.is_onboarding_book || @drawings.count < 5
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_child_profile
      @child_profile = ChildProfile.find(params[:child_profile_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to dashboard_path, alert: t("flash.editor.books.child_not_found")
    end

    def set_book
      @book = @child_profile.books.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to child_profile_books_path(@child_profile), alert: t("flash.editor.books.book_not_found")
    end

    def authorize_editor_access
      unless @book.editable_by?(current_user)
        redirect_to child_profile_book_path(@child_profile, @book),
                    alert: t("flash.editor.books.no_permission")
      end
    end

    def book_params
      params.require(:book).permit(:title, :dedication, :edit_mode)
    end
  end
end
