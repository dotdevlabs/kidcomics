# frozen_string_literal: true

require "test_helper"

class StoryGenerationTest < ActiveSupport::TestCase
  def setup
    user = users(:one)
    family_account = user.family_account || user.create_family_account!(name: "Test Family")
    child_profile = family_account.child_profiles.first || family_account.child_profiles.create!(name: "Test Child", age: 8)
    @book = child_profile.books.create!(title: "Test Book")
    @story_generation = StoryGeneration.create!(
      book: @book,
      status: :pending,
      story_outline: "A great adventure story",
      prompt_template: "Create an adventure story"
    )
  end

  test "should belong to book" do
    assert_respond_to @story_generation, :book
    assert_equal @book, @story_generation.book
  end

  test "should have many page_generations" do
    assert_respond_to @story_generation, :page_generations
  end

  test "should have many character_extractions" do
    assert_respond_to @story_generation, :character_extractions
  end

  test "should validate presence of book" do
    story_generation = StoryGeneration.new(status: :pending)
    assert_not story_generation.valid?
    assert_includes story_generation.errors[:book], "must exist"
  end

  test "should have valid status enum" do
    assert @story_generation.status_pending?

    @story_generation.update!(status: :analyzing_drawings)
    assert @story_generation.status_analyzing_drawings?

    @story_generation.update!(status: :generating_story)
    assert @story_generation.status_generating_story?

    @story_generation.update!(status: :generating_illustrations)
    assert @story_generation.status_generating_illustrations?

    @story_generation.update!(status: :completed)
    assert @story_generation.status_completed?

    @story_generation.update!(status: :failed)
    assert @story_generation.status_failed?
  end

  test "should return correct total_pages" do
    3.times do |i|
      PageGeneration.create!(
        story_generation: @story_generation,
        book: @book,
        page_number: i + 1,
        status: :pending
      )
    end

    assert_equal 3, @story_generation.total_pages
  end

  test "should return correct completed_pages" do
    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 1,
      status: :completed
    )
    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 2,
      status: :pending
    )

    assert_equal 1, @story_generation.completed_pages
  end

  test "should return correct failed_pages" do
    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 1,
      status: :failed
    )
    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 2,
      status: :completed
    )

    assert_equal 1, @story_generation.failed_pages
  end

  test "should calculate progress_percentage correctly" do
    assert_equal 0, @story_generation.progress_percentage

    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 1,
      status: :completed
    )
    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 2,
      status: :pending
    )

    assert_equal 50, @story_generation.progress_percentage
  end

  test "mark_as_completed! should update status and completed_at" do
    freeze_time do
      @story_generation.mark_as_completed!

      assert @story_generation.status_completed?
      assert_equal Time.current, @story_generation.completed_at
    end
  end

  test "mark_as_failed! should update status, error_message, and completed_at" do
    freeze_time do
      error_msg = "Something went wrong"
      @story_generation.mark_as_failed!(error_msg)

      assert @story_generation.status_failed?
      assert_equal error_msg, @story_generation.error_message
      assert_equal Time.current, @story_generation.completed_at
    end
  end

  test "all_pages_completed? should return true when all pages are completed" do
    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 1,
      status: :completed
    )
    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 2,
      status: :completed
    )

    assert @story_generation.all_pages_completed?
  end

  test "all_pages_completed? should return false when some pages are not completed" do
    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 1,
      status: :completed
    )
    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 2,
      status: :pending
    )

    assert_not @story_generation.all_pages_completed?
  end

  test "has_failures? should return true when there are failed pages" do
    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 1,
      status: :failed
    )

    assert @story_generation.has_failures?
  end

  test "has_failures? should return false when there are no failed pages" do
    PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 1,
      status: :completed
    )

    assert_not @story_generation.has_failures?
  end

  test "should scope recent correctly" do
    # Destroy the story generation created in setup to avoid confusion
    @story_generation.destroy!

    older = nil
    newer = nil

    # Freeze time to ensure deterministic ordering
    travel_to 2.days.ago do
      older = StoryGeneration.create!(
        book: @book,
        status: :pending
      )
    end

    travel_to 1.day.ago do
      newer = StoryGeneration.create!(
        book: @book,
        status: :pending
      )
    end

    recent = StoryGeneration.recent.limit(2)
    assert_equal newer.id, recent.first.id
    assert_equal older.id, recent.second.id
  end

  test "should scope completed correctly" do
    completed = StoryGeneration.create!(
      book: @book,
      status: :completed
    )
    pending = StoryGeneration.create!(
      book: @book,
      status: :pending
    )

    assert_includes StoryGeneration.completed, completed
    assert_not_includes StoryGeneration.completed, pending
  end

  test "should scope failed correctly" do
    failed = StoryGeneration.create!(
      book: @book,
      status: :failed
    )
    completed = StoryGeneration.create!(
      book: @book,
      status: :completed
    )

    assert_includes StoryGeneration.failed, failed
    assert_not_includes StoryGeneration.failed, completed
  end

  test "should scope in_progress correctly" do
    pending = StoryGeneration.create!(book: @book, status: :pending)
    analyzing = StoryGeneration.create!(book: @book, status: :analyzing_drawings)
    generating_story = StoryGeneration.create!(book: @book, status: :generating_story)
    generating_illustrations = StoryGeneration.create!(book: @book, status: :generating_illustrations)
    completed = StoryGeneration.create!(book: @book, status: :completed)
    failed = StoryGeneration.create!(book: @book, status: :failed)

    in_progress = StoryGeneration.in_progress
    assert_includes in_progress, pending
    assert_includes in_progress, analyzing
    assert_includes in_progress, generating_story
    assert_includes in_progress, generating_illustrations
    assert_not_includes in_progress, completed
    assert_not_includes in_progress, failed
  end
end
