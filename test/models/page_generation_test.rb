# frozen_string_literal: true

require "test_helper"

class PageGenerationTest < ActiveSupport::TestCase
  def setup
    user = users(:one)
    family_account = user.family_account || user.create_family_account!(name: "Test Family")
    child_profile = family_account.child_profiles.first || family_account.child_profiles.create!(name: "Test Child", age: 8)
    @book = child_profile.books.create!(title: "Test Book")
    @story_generation = StoryGeneration.create!(
      book: @book,
      status: :pending,
      story_outline: "A great adventure",
      prompt_template: "Create an adventure story"
    )
    @page_generation = PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 1,
      status: :pending,
      narration_text: "Once upon a time..."
    )
  end

  test "should belong to story_generation" do
    assert_respond_to @page_generation, :story_generation
    assert_equal @story_generation, @page_generation.story_generation
  end

  test "should validate presence of story_generation" do
    page = PageGeneration.new(page_number: 1, status: :pending)
    assert_not page.valid?
    assert_includes page.errors[:story_generation], "must exist"
  end

  test "should validate presence of page_number" do
    page = PageGeneration.new(story_generation: @story_generation, status: :pending)
    assert_not page.valid?
    assert_includes page.errors[:page_number], "can't be blank"
  end

  test "should have valid status enum" do
    assert @page_generation.status_pending?

    @page_generation.update!(status: :generating)
    assert @page_generation.status_generating?

    @page_generation.update!(status: :completed)
    assert @page_generation.status_completed?

    @page_generation.update!(status: :failed)
    assert @page_generation.status_failed?
  end

  test "mark_as_completed! should update status, generation_time, and cost" do
    @page_generation.mark_as_completed!(generation_time: 10.5, cost_cents: 150)

    assert @page_generation.status_completed?
    assert_equal 10.5, @page_generation.generation_time_seconds
    assert_equal 150, @page_generation.cost_cents
    assert_nil @page_generation.error_message
  end

  test "mark_as_failed! should update status and error_message" do
    error_msg = "Generation failed"
    @page_generation.mark_as_failed!(error_msg)

    assert @page_generation.status_failed?
    assert_equal error_msg, @page_generation.error_message
  end

  test "should track generation time" do
    @page_generation.update!(generation_time_seconds: 10.5)

    assert_equal 10.5, @page_generation.generation_time_seconds
  end

  test "should track generation cost" do
    @page_generation.update!(
      cost_cents: 150
    )

    assert_equal 150, @page_generation.cost_cents
  end

  test "should scope completed correctly" do
    completed = PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 2,
      status: :completed
    )
    pending = PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 3,
      status: :pending
    )

    assert_includes PageGeneration.status_completed, completed
    assert_not_includes PageGeneration.status_completed, pending
  end

  test "should scope failed correctly" do
    failed = PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 2,
      status: :failed
    )
    completed = PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 3,
      status: :completed
    )

    assert_includes PageGeneration.status_failed, failed
    assert_not_includes PageGeneration.status_failed, completed
  end

  test "should order by page_number" do
    page3 = PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 3,
      status: :pending
    )
    page2 = PageGeneration.create!(
      story_generation: @story_generation,
      book: @book,
      page_number: 2,
      status: :pending
    )

    pages = @story_generation.page_generations.ordered
    assert_equal 1, pages.first.page_number
    assert_equal 2, pages.second.page_number
    assert_equal 3, pages.third.page_number
  end
end
