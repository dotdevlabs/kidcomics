# frozen_string_literal: true

require "test_helper"

module AI
  class StoryGenerationServiceTest < ActiveSupport::TestCase
    def setup
      @book = books(:one)
      @book.update!(ai_generation_enabled: true)
      @user_prompt = "Create an adventure story"
    end

    test "should create story generation and enqueue job" do
      drawing = @book.drawings.create!(
        title: "Test Drawing",
        image: fixture_file_upload("test_image.jpg", "image/jpeg")
      )

      assert_difference "StoryGeneration.count", 1 do
        assert_enqueued_with(job: AI::AnalyzeDrawingsJob) do
          service = StoryGenerationService.new(book: @book, user_prompt: @user_prompt)
          result = service.call

          assert_not_nil result
          assert_equal @book, result.book
          assert_equal @user_prompt, result.prompt_template
          assert result.status_pending?
        end
      end
    end

    test "should raise validation error when book has no drawings" do
      @book.drawings.destroy_all

      service = StoryGenerationService.new(book: @book, user_prompt: @user_prompt)

      assert_raises(StoryGenerationService::ValidationError, "Book must have drawings") do
        service.call
      end
    end

    test "should raise validation error when AI generation is disabled" do
      drawing = @book.drawings.create!(
        title: "Test Drawing",
        image: fixture_file_upload("test_image.jpg", "image/jpeg")
      )
      @book.update!(ai_generation_enabled: false)

      service = StoryGenerationService.new(book: @book, user_prompt: @user_prompt)

      assert_raises(StoryGenerationService::ValidationError, "AI generation is disabled for this book") do
        service.call
      end
    end

    test "should raise validation error when prompt is blank" do
      drawing = @book.drawings.create!(
        title: "Test Drawing",
        image: fixture_file_upload("test_image.jpg", "image/jpeg")
      )

      service = StoryGenerationService.new(book: @book, user_prompt: "")

      assert_raises(StoryGenerationService::ValidationError, "Story prompt is required") do
        service.call
      end
    end
  end
end
