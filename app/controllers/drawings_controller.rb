class DrawingsController < ApplicationController
  before_action :set_child_profile_and_book
  before_action :set_drawing, only: [ :edit, :update, :destroy ]

  def index
    @drawings = @book.drawings.ordered
  end

  def new
    @drawing = @book.drawings.build
    @is_onboarding_book = @book.is_onboarding_book?
    @page_limit = @is_onboarding_book ? 5 : nil
    @current_page_count = @book.drawings.count
  end

  def create
    uploaded_images = params[:drawing][:images] || []

    if uploaded_images.empty?
      flash.now[:alert] = t("flash.drawings.no_images")
      @drawing = @book.drawings.build
      render :new, status: :unprocessable_entity
      return
    end

    # Check page limit for onboarding books
    if @book.is_onboarding_book?
      current_count = @book.drawings.count
      remaining = 5 - current_count

      if remaining <= 0
        flash[:alert] = t("flash.drawings.page_limit_reached")
        redirect_to child_profile_book_drawings_path(@child_profile, @book)
        return
      end

      if uploaded_images.count > remaining
        flash[:alert] = t("flash.drawings.page_limit_exceeded", remaining: remaining)
        redirect_to child_profile_book_drawings_path(@child_profile, @book)
        return
      end
    end

    saved_count = 0
    uploaded_images.each do |image|
      drawing = @book.drawings.build(drawing_params.except(:images))
      drawing.image.attach(image)

      if drawing.save
        saved_count += 1
      end
    end

    if saved_count > 0
      notice_message = if @book.is_onboarding_book? && @book.drawings.count > 0
        t("flash.drawings.uploaded_with_notice", count: saved_count)
      else
        t("flash.drawings.uploaded", count: saved_count)
      end

      redirect_to child_profile_book_drawings_path(@child_profile, @book),
                  notice: notice_message
    else
      flash.now[:alert] = t("flash.drawings.upload_failed")
      @drawing = @book.drawings.build
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @drawing.update(drawing_params.except(:images))
      # Handle image replacement if new image is uploaded
      if params[:drawing][:image].present?
        @drawing.image.attach(params[:drawing][:image])
      end

      redirect_to child_profile_book_drawings_path(@child_profile, @book),
                  notice: t("flash.drawings.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @drawing.destroy
    redirect_to child_profile_book_drawings_path(@child_profile, @book),
                notice: t("flash.drawings.deleted")
  end

  private

  def set_child_profile_and_book
    @child_profile = ChildProfile.find(params[:child_profile_id])
    @book = @child_profile.books.find(params[:book_id])
  end

  def set_drawing
    @drawing = @book.drawings.find(params[:id])
  end

  def drawing_params
    params.require(:drawing).permit(:tag, :caption, :image, images: [])
  end
end
