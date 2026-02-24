class LibraryController < ApplicationController
  before_action :require_login
  before_action :set_family_account

  def index
    @books = @family_account.all_books

    # Apply search
    @books = @books.search_by_title(params[:search]) if params[:search].present?

    # Apply filters
    @books = apply_filters(@books)

    # Apply sorting
    @books = apply_sorting(@books)

    # Get statistics
    @statistics = @family_account.family_book_statistics

    # Store view mode (grid or list)
    @view_mode = params[:view_mode] || "grid"

    # Get all child profiles for filtering
    @child_profiles = @family_account.child_profiles.order(:name)
  end

  private

  def set_family_account
    @family_account = current_user.family_account
    unless @family_account
      flash[:alert] = "You must have a family account to access the library."
      redirect_to root_path
    end
  end

  def apply_filters(books)
    # Filter by child profile
    if params[:child_profile_id].present?
      books = books.where(child_profile_id: params[:child_profile_id])
    end

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
