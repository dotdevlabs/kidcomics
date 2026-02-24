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

    test "should update status and enqueue next job on success" do
      # Create a drawing for the book
      drawing = @book.drawings.create!(
        title: "Test Drawing",
        image: fixture_file_upload("test_image.jpg", "image/jpeg")
      )

      # Mock the drawing analysis service
      mock_service = Minitest::Mock.new
      mock_service.expect(:call, drawing)

      AI::DrawingAnalysisService.stub(:new, mock_service) do
        assert_enqueued_with(job: AI::GenerateStoryOutlineJob) do
          AnalyzeDrawingsJob.perform_now(@story_generation.id)
        end
      end

      @story_generation.reload
      assert @story_generation.status_analyzing_drawings?
    end

    test "should handle errors and mark story generation as failed" do
      drawing = @book.drawings.create!(
        title: "Test Drawing",
        image: fixture_file_upload("test_image.jpg", "image/jpeg")
      )

      # Mock service to raise an error
      AI::DrawingAnalysisService.stub(:new, -> { raise StandardError.new("API error") }) do
        assert_raises(StandardError) do
          AnalyzeDrawingsJob.perform_now(@story_generation.id)
        end
      end

      @story_generation.reload
      assert @story_generation.status_failed?
      assert_includes @story_generation.error_message, "API error"
    end

    test "should skip drawings without images" do
      drawing_with_image = @book.drawings.create!(
        title: "With Image",
        image: fixture_file_upload("test_image.jpg", "image/jpeg")
      )
      drawing_without_image = @book.drawings.create!(title: "Without Image")

      mock_service = Minitest::Mock.new
      mock_service.expect(:call, drawing_with_image)

      AI::DrawingAnalysisService.stub(:new, mock_service) do
        AnalyzeDrawingsJob.perform_now(@story_generation.id)
      end

      # Should only call service once for the drawing with image
      mock_service.verify
    end
  end
end
