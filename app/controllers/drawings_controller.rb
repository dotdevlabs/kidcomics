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
      flash.now[:alert] = "Please select at least one image to upload."
      @drawing = @book.drawings.build
      render :new, status: :unprocessable_entity
      return
    end

    # Check page limit for onboarding books
    if @book.is_onboarding_book?
      current_count = @book.drawings.count
      remaining = 5 - current_count

      if remaining <= 0
        flash[:alert] = "This book has reached the 5-page limit for onboarding. Please complete your account setup to create unlimited books."
        redirect_to child_profile_book_drawings_path(@child_profile, @book)
        return
      end

      if uploaded_images.count > remaining
        flash[:alert] = "You can only add #{remaining} more page(s) to this onboarding book (5-page limit)."
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
      notice_message = "#{saved_count} drawing(s) uploaded successfully."

      # If this book now has drawings and user hasn't completed onboarding, prompt to complete
      if @book.is_onboarding_book? && @book.drawings.count > 0
        notice_message += " When you're ready, complete your account setup to unlock unlimited books!"
      end

      redirect_to child_profile_book_drawings_path(@child_profile, @book),
                  notice: notice_message
    else
      flash.now[:alert] = "Failed to upload drawings. Please check file size and format."
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
                  notice: "Drawing was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @drawing.destroy
    redirect_to child_profile_book_drawings_path(@child_profile, @book),
                notice: "Drawing was successfully deleted."
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
