require "test_helper"

class DrawingImageProcessorTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Test User", email: "processor_test@example.com", password: "password123")
    @family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    @child_profile = ChildProfile.create!(name: "Test Child", age: 8, family_account: @family_account)
    @book = Book.create!(title: "Test Book", child_profile: @child_profile)
  end

  test "process! sets processing_status to processed on valid image" do
    drawing = Drawing.create!(book: @book, position: 99)
    drawing.image.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "test_drawing.jpg")),
      filename: "test_drawing.jpg",
      content_type: "image/jpeg"
    )

    DrawingImageProcessor.new(drawing).process!

    drawing.reload
    assert drawing.processing_status_processed?
  end

  test "process! re-attaches a processed image" do
    drawing = Drawing.create!(book: @book, position: 99)
    drawing.image.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "test_drawing.jpg")),
      filename: "test_drawing.jpg",
      content_type: "image/jpeg"
    )
    original_key = drawing.image.blob.key

    DrawingImageProcessor.new(drawing).process!

    drawing.reload
    assert drawing.image.attached?
    assert_not_equal original_key, drawing.image.blob.key
    assert_equal "image/jpeg", drawing.image.blob.content_type
  end

  test "process! raises ProcessingError on corrupt image" do
    drawing = Drawing.create!(book: @book, position: 99)
    drawing.image.attach(
      io: StringIO.new("this is not a valid image at all CORRUPTED DATA"),
      filename: "corrupt.jpg",
      content_type: "image/jpeg"
    )

    assert_raises(DrawingImageProcessor::ProcessingError) do
      DrawingImageProcessor.new(drawing).process!
    end
  end

  test "process! sets processing_status to failed on corrupt image" do
    drawing = Drawing.create!(book: @book, position: 99)
    drawing.image.attach(
      io: StringIO.new("this is not a valid image at all CORRUPTED DATA"),
      filename: "corrupt.jpg",
      content_type: "image/jpeg"
    )

    begin
      DrawingImageProcessor.new(drawing).process!
    rescue DrawingImageProcessor::ProcessingError
      nil
    end

    drawing.reload
    assert drawing.processing_status_failed?
  end
end
