module Admin
  class ContentController < BaseController
    before_action :set_book, only: [ :show, :approve, :flag, :reject ]

    def index
      @books = Book.includes(child_profile: { family_account: :owner })
                   .order(created_at: :desc)
                   .limit(100)

      # Apply filters
      case params[:filter]
      when "pending"
        @books = @books.moderation_pending_review
      when "flagged"
        @books = @books.moderation_flagged
      when "approved"
        @books = @books.moderation_approved
      when "rejected"
        @books = @books.moderation_rejected
      when "needs_review"
        @books = @books.needs_moderation
      end

      @books = @books.where("books.title ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    end

    def show
      @drawings = @book.drawings.order(position: :asc)
      @story_generations = @book.story_generations.order(created_at: :desc).limit(5)
      @page_generations = @book.page_generations.order(page_number: :asc).limit(10)
      @admin_actions = AdminAction.where(target: @book).recent.limit(5)
    end

    def approve
      @book.update!(moderation_status: :approved)
      log_admin_action("content_approved", @book)

      flash[:notice] = "Content approved successfully."
      redirect_to admin_content_path(@book)
    end

    def flag
      @book.update!(moderation_status: :flagged)
      log_admin_action(
        "content_flagged",
        @book,
        { reason: params[:reason] }
      )

      flash[:notice] = "Content flagged for review."
      redirect_to admin_content_path(@book)
    end

    def reject
      @book.update!(moderation_status: :rejected)
      log_admin_action(
        "content_rejected",
        @book,
        { reason: params[:reason] }
      )

      flash[:notice] = "Content rejected."
      redirect_to admin_content_path(@book)
    end

    private

    def set_book
      @book = Book.includes(child_profile: { family_account: :owner }).find(params[:id])
    end
  end
end
