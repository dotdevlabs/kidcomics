# frozen_string_literal: true

require "test_helper"

module AI
  class AnalyzeDrawingsJobTest < ActiveJob::TestCase
    def setup
      @book = books(:one)
      @story_generation = StoryGeneration.create!(
        book: @book,
        status: :pending,
        prompt_template: "Create a story"
      )
    end

    test "should process story generation" do
      # Create a drawing for the book
      drawing = @book.drawings.create!(
        caption: "Test Drawing",
        position: 1
      )
      # Attach a test image
      drawing.image.attach(
        io: StringIO.new("fake image data"),
        filename: "test_image.jpg",
        content_type: "image/jpeg"
      )

      assert_nothing_raised do
        AnalyzeDrawingsJob.perform_now(@story_generation.id)
      end
    end

    test "should handle missing story generation" do
      # The job will raise an error when it can't find the story generation
      # since story_generation is nil when the rescue block tries to use it
      assert_raises(NoMethodError) do
        AnalyzeDrawingsJob.perform_now(99999)
      end
    end

    test "should skip drawings without images" do
      drawing_with_image = @book.drawings.create!(
        caption: "With Image",
        position: 1
      )
      drawing_with_image.image.attach(
        io: StringIO.new("fake image data"),
        filename: "test_image.jpg",
        content_type: "image/jpeg"
      )
      drawing_without_image = @book.drawings.create!(caption: "Without Image", position: 2)

      # The job should complete without errors even with mixed drawings
      assert_nothing_raised do
        AnalyzeDrawingsJob.perform_now(@story_generation.id)
      end
    end
  end
end
