# frozen_string_literal: true

require "test_helper"

module AI
  class StoryGenerationsControllerTest < ActionDispatch::IntegrationTest
    def setup
      @user = users(:one)
      @family_account = @user.family_account
      @child_profile = @family_account.child_profiles.first || @family_account.child_profiles.create!(
        name: "Test Child",
        age: 8
      )
      @book = @child_profile.books.first || @child_profile.books.create!(title: "Test Book")
      @book.update!(ai_generation_enabled: true)

      # Create a drawing for the book
      @book.drawings.create!(
        title: "Test Drawing",
        image: fixture_file_upload("test_image.jpg", "image/jpeg")
      )

      post session_path, params: { email: @user.email, password: "password" }
    end

    test "should get new" do
      get new_ai_child_profile_book_story_generation_path(@child_profile, @book)
      assert_response :success
    end

    test "should create story generation" do
      assert_difference("StoryGeneration.count") do
        post ai_child_profile_book_story_generations_path(@child_profile, @book),
             params: { story_generation: { story_prompt: "Create an adventure story" } }
      end

      assert_redirected_to ai_child_profile_book_story_generation_path(
        @child_profile,
        @book,
        StoryGeneration.last
      )
      assert_equal "Story generation started! This may take a few minutes.", flash[:notice]
    end

    test "should not create story generation with blank prompt" do
      assert_no_difference("StoryGeneration.count") do
        post ai_child_profile_book_story_generations_path(@child_profile, @book),
             params: { story_generation: { story_prompt: "" } }
      end

      assert_response :unprocessable_entity
    end

    test "should show story generation" do
      story_generation = @book.story_generations.create!(
        status: :pending,
        prompt_template: "Test story"
      )

      get ai_child_profile_book_story_generation_path(@child_profile, @book, story_generation)
      assert_response :success
    end

    test "should retry failed story generation" do
      story_generation = @book.story_generations.create!(
        status: :failed,
        prompt_template: "Test story",
        error_message: "Something went wrong"
      )

      assert_enqueued_with(job: AI::AnalyzeDrawingsJob) do
        post retry_ai_child_profile_book_story_generation_path(@child_profile, @book, story_generation)
      end

      story_generation.reload
      assert story_generation.status_pending?
      assert_nil story_generation.error_message

      assert_redirected_to ai_child_profile_book_story_generation_path(@child_profile, @book, story_generation)
      assert_equal "Retrying story generation...", flash[:notice]
    end

    test "should not retry non-failed story generation" do
      story_generation = @book.story_generations.create!(
        status: :pending,
        prompt_template: "Test story"
      )

      post retry_ai_child_profile_book_story_generation_path(@child_profile, @book, story_generation)

      assert_redirected_to ai_child_profile_book_story_generation_path(@child_profile, @book, story_generation)
      assert_equal "Cannot retry a generation that is not failed.", flash[:alert]
    end

    test "should require login" do
      delete session_path

      get new_ai_child_profile_book_story_generation_path(@child_profile, @book)
      assert_redirected_to login_path
    end
  end
end
