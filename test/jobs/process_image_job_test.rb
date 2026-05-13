require "test_helper"

class ProcessImageJobTest < ActiveJob::TestCase
  setup do
    @user = User.create!(name: "Job Test User", email: "job_test@example.com", password: "password123")
    @family_account = FamilyAccount.create!(name: "Job Test Family", owner: @user)
    @child_profile = ChildProfile.create!(name: "Job Test Child", age: 7, family_account: @family_account)
    @book = Book.create!(title: "Job Test Book", child_profile: @child_profile)
  end

  test "job returns early for missing drawing" do
    assert_nothing_raised do
      ProcessImageJob.perform_now(999_999)
    end
  end

  test "job skips already processed drawing" do
    drawing = create_drawing_with_image
    drawing.update_column(:processing_status, Drawing.processing_statuses[:processed])

    ProcessImageJob.perform_now(drawing.id)

    drawing.reload
    assert drawing.processing_status_processed?, "Status should remain processed"
  end

  test "job sets drawing to processed on success" do
    drawing = create_drawing_with_image

    ProcessImageJob.perform_now(drawing.id)

    drawing.reload
    assert drawing.processing_status_processed?
  end

  test "job sets drawing to failed on corrupt image" do
    drawing = create_drawing_with_corrupt_image

    ProcessImageJob.perform_now(drawing.id)

    drawing.reload
    assert drawing.processing_status_failed?
  end

  test "creating drawing with image enqueues ProcessImageJob" do
    drawing = Drawing.new(book: @book, position: 99)
    drawing.image.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "test_drawing.jpg")),
      filename: "test_drawing.jpg",
      content_type: "image/jpeg"
    )

    assert_enqueued_with(job: ProcessImageJob) do
      drawing.save!
    end
  end

  private

  def create_drawing_with_image
    drawing = Drawing.create!(book: @book, position: 99)
    drawing.image.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "test_drawing.jpg")),
      filename: "test_drawing.jpg",
      content_type: "image/jpeg"
    )
    drawing
  end

  def create_drawing_with_corrupt_image
    drawing = Drawing.create!(book: @book, position: 98)
    drawing.image.attach(
      io: StringIO.new("not a valid image CORRUPTED BYTES \x00\x01\x02"),
      filename: "corrupt.jpg",
      content_type: "image/jpeg"
    )
    drawing
  end
end
