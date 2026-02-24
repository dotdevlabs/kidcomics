class BooksController < ApplicationController
  before_action :set_child_profile
  before_action :set_book, only: [ :show, :edit, :update, :destroy ]

  def index
    @books = @child_profile.books.recent
  end

  def show
    @drawings = @book.drawings.ordered
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
end
