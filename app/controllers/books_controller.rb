class BooksController < ApplicationController
  before_action :set_child_profile
  before_action :set_book, only: [ :show, :edit, :update, :destroy, :toggle_favorite ]

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
    @book = @child_profile.books.build
  end

  def create
    @book = @child_profile.books.build(book_params)

    if @book.save
      redirect_to child_profile_book_path(@child_profile, @book), notice: "Book was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to child_profile_book_path(@child_profile, @book), notice: "Book was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
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
end
