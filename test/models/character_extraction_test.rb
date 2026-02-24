# frozen_string_literal: true

require "test_helper"

class CharacterExtractionTest < ActiveSupport::TestCase
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
    @drawing = @book.drawings.new
    @drawing.image.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")),
      filename: "test_image.jpg",
      content_type: "image/jpeg"
    )
    @drawing.save!
    @character_extraction = CharacterExtraction.create!(
      story_generation: @story_generation,
      drawing: @drawing,
      character_name: "Hero",
      description: "A brave young hero",
      color_palette: { hair: "brown", eyes: "blue" },
      proportions: { height: "small" },
      status: :completed
    )
  end

  test "should belong to story_generation" do
    assert_respond_to @character_extraction, :story_generation
    assert_equal @story_generation, @character_extraction.story_generation
  end

  test "should belong to drawing" do
    assert_respond_to @character_extraction, :drawing
    assert_equal @drawing, @character_extraction.drawing
  end

  test "should validate presence of story_generation" do
    character = CharacterExtraction.new(
      drawing: @drawing,
      character_name: "Hero"
    )
    assert_not character.valid?
    assert_includes character.errors[:story_generation], "must exist"
  end

  test "should validate presence of drawing" do
    character = CharacterExtraction.new(
      story_generation: @story_generation,
      character_name: "Hero"
    )
    assert_not character.valid?
    assert_includes character.errors[:drawing], "must exist"
  end

  test "should validate uniqueness of drawing per story_generation" do
    # First character extraction already exists from setup
    character = CharacterExtraction.new(
      story_generation: @story_generation,
      drawing: @drawing,
      status: :completed
    )
    assert_not character.valid?
    assert_includes character.errors[:drawing_id], "has already been taken"
  end

  test "should store color_palette as JSON" do
    palette = {
      hair_color: "brown",
      eye_color: "blue",
      clothing: "red shirt"
    }

    @character_extraction.update!(color_palette: palette)
    @character_extraction.reload

    assert_equal "brown", @character_extraction.color_palette["hair_color"]
    assert_equal "blue", @character_extraction.color_palette["eye_color"]
    assert_equal "red shirt", @character_extraction.color_palette["clothing"]
  end

  test "should store description as text" do
    description = "A very detailed description of the character's appearance and personality"
    @character_extraction.update!(description: description)

    assert_equal description, @character_extraction.description
  end

  test "should store proportions as JSON" do
    props = {
      height: "small",
      head_size: "large",
      body_type: "thin"
    }
    @character_extraction.update!(proportions: props)
    @character_extraction.reload

    assert_equal "small", @character_extraction.proportions["height"]
    assert_equal "large", @character_extraction.proportions["head_size"]
    assert_equal "thin", @character_extraction.proportions["body_type"]
  end

  test "should allow multiple characters per story_generation from different drawings" do
    drawing2 = @book.drawings.new
    drawing2.image.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")),
      filename: "test_image2.jpg",
      content_type: "image/jpeg"
    )
    drawing2.save!

    character2 = CharacterExtraction.create!(
      story_generation: @story_generation,
      drawing: drawing2,
      character_name: "Sidekick",
      description: "A loyal companion",
      status: :completed
    )

    assert_equal 2, @story_generation.character_extractions.count
    assert_includes @story_generation.character_extractions, @character_extraction
    assert_includes @story_generation.character_extractions, character2
  end
end
