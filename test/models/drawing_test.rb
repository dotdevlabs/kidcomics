require "test_helper"

class DrawingTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    @child_profile = ChildProfile.create!(name: "Test Child", age: 8, family_account: @family_account)
    @book = Book.create!(title: "Test Book", child_profile: @child_profile)
  end

  test "valid drawing" do
    drawing = Drawing.new(book: @book, position: 0)
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert drawing.valid?
  end

  test "belongs to book" do
    drawing = Drawing.create!(book: @book, position: 0)
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert_equal @book, drawing.book
  end

  test "position defaults to next position" do
    drawing1 = Drawing.create!(book: @book)
    drawing1.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test1.jpg", content_type: "image/jpeg")

    drawing2 = Drawing.create!(book: @book)
    drawing2.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test2.jpg", content_type: "image/jpeg")

    assert_equal 0, drawing1.position
    assert_equal 1, drawing2.position
  end

  test "position can be manually set" do
    drawing = Drawing.create!(book: @book, position: 5)
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert_equal 5, drawing.position
  end

  test "tag can be character, background, or object" do
    drawing = Drawing.create!(book: @book, position: 0, tag: "character")
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert_equal "character", drawing.tag

    drawing.update(tag: "background")
    assert_equal "background", drawing.tag

    drawing.update(tag: "object")
    assert_equal "object", drawing.tag
  end

  test "tag can be nil" do
    drawing = Drawing.create!(book: @book, position: 0)
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert_nil drawing.tag
  end

  test "tag must be valid value" do
    drawing = Drawing.new(book: @book, position: 0, tag: "invalid")
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert_not drawing.valid?
    assert_includes drawing.errors[:tag], "is not included in the list"
  end

  test "ordered scope returns drawings by position" do
    drawing3 = Drawing.create!(book: @book, position: 2)
    drawing3.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test3.jpg", content_type: "image/jpeg")

    drawing1 = Drawing.create!(book: @book, position: 0)
    drawing1.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test1.jpg", content_type: "image/jpeg")

    drawing2 = Drawing.create!(book: @book, position: 1)
    drawing2.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test2.jpg", content_type: "image/jpeg")

    assert_equal [ drawing1, drawing2, drawing3 ], Drawing.ordered.to_a
  end

  test "tagged scope filters by tag" do
    character_drawing = Drawing.create!(book: @book, position: 0, tag: "character")
    character_drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "character.jpg", content_type: "image/jpeg")

    background_drawing = Drawing.create!(book: @book, position: 1, tag: "background")
    background_drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "background.jpg", content_type: "image/jpeg")

    assert_equal [ character_drawing ], Drawing.tagged("character").to_a
    assert_equal [ background_drawing ], Drawing.tagged("background").to_a
  end

  test "has_one_attached image" do
    drawing = Drawing.create!(book: @book, position: 0)
    assert_respond_to drawing, :image
    assert_not drawing.image.attached?

    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert drawing.image.attached?
  end

  test "caption is optional" do
    drawing = Drawing.create!(book: @book, position: 0)
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert_nil drawing.caption

    drawing.update(caption: "A cool drawing")
    assert_equal "A cool drawing", drawing.caption
  end

  # Editor feature tests
  test "narration_text is optional" do
    drawing = Drawing.create!(book: @book, position: 0)
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert_nil drawing.narration_text

    drawing.update(narration_text: "Once upon a time...")
    assert_equal "Once upon a time...", drawing.narration_text
  end

  test "dialogue_text is optional" do
    drawing = Drawing.create!(book: @book, position: 0)
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert_nil drawing.dialogue_text

    drawing.update(dialogue_text: "\"Hello!\" said the hero.")
    assert_equal "\"Hello!\" said the hero.", drawing.dialogue_text
  end

  test "is_cover defaults to false" do
    drawing = Drawing.create!(book: @book, position: 0)
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert_equal false, drawing.is_cover
  end

  test "is_cover can be set to true" do
    drawing = Drawing.create!(book: @book, position: 0, is_cover: true)
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert_equal true, drawing.is_cover
  end

  test "has_text? returns true when narration_text is present" do
    drawing = Drawing.create!(book: @book, position: 0, narration_text: "Some text")
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert drawing.has_text?
  end

  test "has_text? returns true when dialogue_text is present" do
    drawing = Drawing.create!(book: @book, position: 0, dialogue_text: "Some dialogue")
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert drawing.has_text?
  end

  test "has_text? returns false when no text is present" do
    drawing = Drawing.create!(book: @book, position: 0)
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert_not drawing.has_text?
  end

  test "combined_text returns both narration and dialogue" do
    drawing = Drawing.create!(
      book: @book,
      position: 0,
      narration_text: "Once upon a time...",
      dialogue_text: "\"Hello!\" said the hero."
    )
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")

    expected = "Once upon a time...\n\n\"Hello!\" said the hero."
    assert_equal expected, drawing.combined_text
  end

  test "covers scope returns only cover drawings" do
    cover = Drawing.create!(book: @book, position: 0, is_cover: true)
    cover.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "cover.jpg", content_type: "image/jpeg")

    page = Drawing.create!(book: @book, position: 1, is_cover: false)
    page.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "page.jpg", content_type: "image/jpeg")

    assert_equal [ cover ], Drawing.covers.to_a
  end

  test "pages scope returns only non-cover drawings" do
    cover = Drawing.create!(book: @book, position: 0, is_cover: true)
    cover.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "cover.jpg", content_type: "image/jpeg")

    page = Drawing.create!(book: @book, position: 1, is_cover: false)
    page.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "page.jpg", content_type: "image/jpeg")

    assert_equal [ page ], Drawing.pages.to_a
  end
end
