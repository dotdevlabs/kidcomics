class BooksController < ApplicationController
  before_action :set_child_profile
  before_action :set_book, only: [ :show, :edit, :update, :destroy, :toggle_favorite ]
  before_action :check_onboarding_status, only: [ :new, :create ]

  def index
    @books = @child_profile.books

    # Apply search
    @books = @books.search_by_title(params[:search]) if params[:search].present?

    # Apply filters
    @books = apply_filters(@books)

    # Apply sorting
    @books = apply_sorting(@books)

    # Get statistics
    @statistics = @child_profile.book_statistics

    # Store view mode (grid or list)
    @view_mode = params[:view_mode] || "grid"
  end

  def show
    @book.increment_view_count!
    @drawings = @book.drawings.order(position: :asc)
  end

  def new
    # Photo-first approach: Auto-create book and redirect to photo upload
    # No form barriers - start with creation immediately
    @book = @child_profile.books.create!(
      title: "#{@child_profile.name}'s Story",
      description: "",
      status: "draft"
    )

    # Redirect directly to photo upload (creative first, not administrative)
    redirect_to new_child_profile_book_drawing_path(@child_profile, @book),
      notice: "Let's start by adding your first drawing!"
  end

  def create
    # This action is deprecated in favor of the photo-first approach
    # Redirect to new action which auto-creates and goes to photo upload
    redirect_to new_child_profile_book_path(@child_profile)
  end

  def edit
    # Redirect to the AI-powered editor instead of showing traditional form
    redirect_to edit_editor_child_profile_book_path(@child_profile, @book)
  end

  def update
    # All updates now happen through the AI-powered editor
    # Redirect to editor if someone tries to update through old route
    redirect_to edit_editor_child_profile_book_path(@child_profile, @book),
      notice: "Please use the interactive editor to update your book."
  end

  def destroy
    @book.destroy
    redirect_to child_profile_books_path(@child_profile), notice: "Book was successfully deleted."
  end

  def toggle_favorite
    @book.toggle_favorite!
    respond_to do |format|
      format.html { redirect_to child_profile_books_path(@child_profile), notice: "Book #{@book.favorited? ? 'added to' : 'removed from'} favorites." }
      format.json { render json: { favorited: @book.favorited } }
    end
  end

  private

  def set_child_profile
    @child_profile = ChildProfile.find(params[:child_profile_id])
  end

  def set_book
    @book = @child_profile.books.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :description, :status)
  end

  def apply_filters(books)
    # Filter by status
    if params[:status].present? && params[:status] != "all"
      books = books.where(status: params[:status])
    end

    # Filter by favorited
    if params[:favorited] == "true"
      books = books.favorited
    end

    # Filter by date range
    if params[:date_from].present?
      books = books.created_after(params[:date_from])
    end

    if params[:date_to].present?
      books = books.created_before(params[:date_to])
    end

    books
  end

  def apply_sorting(books)
    case params[:sort]
    when "oldest"
      books.oldest
    when "title"
      books.by_title
    when "popularity"
      books.by_popularity
    else
      books.recent
    end
  end

  def check_onboarding_status
    # Set instance variable for views to check
    @is_onboarding = current_user&.onboarding_completed? == false
  end
end
