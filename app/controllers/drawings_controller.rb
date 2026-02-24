class DrawingsController < ApplicationController
  before_action :set_child_profile_and_book
  before_action :set_drawing, only: [ :edit, :update, :destroy, :reorder ]

  def index
    @drawings = @book.drawings.ordered
  end

  def new
    @drawing = @book.drawings.build
  end

  def create
    uploaded_images = params[:drawing][:images] || []

    if uploaded_images.empty?
      flash.now[:alert] = "Please select at least one image to upload."
      @drawing = @book.drawings.build
      render :new, status: :unprocessable_entity
      return
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
      redirect_to child_profile_book_drawings_path(@child_profile, @book),
                  notice: "#{saved_count} drawing(s) uploaded successfully."
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

  def reorder
    new_position = params[:position].to_i
    old_position = @drawing.position

    if new_position != old_position
      # Reorder drawings
      if new_position < old_position
        # Moving up: increment positions of drawings between new and old position
        @book.drawings.where("position >= ? AND position < ?", new_position, old_position)
              .update_all("position = position + 1")
      else
        # Moving down: decrement positions of drawings between old and new position
        @book.drawings.where("position > ? AND position <= ?", old_position, new_position)
              .update_all("position = position - 1")
      end

      @drawing.update(position: new_position)
    end

    head :ok
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
