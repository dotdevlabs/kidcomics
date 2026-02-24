require "test_helper"

class BookTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    @child_profile = ChildProfile.create!(name: "Test Child", age: 8, family_account: @family_account)
  end

  test "valid book" do
    book = Book.new(title: "My First Comic", child_profile: @child_profile)
    assert book.valid?
  end

  test "requires title" do
    book = Book.new(child_profile: @child_profile)
    assert_not book.valid?
    assert_includes book.errors[:title], "can't be blank"
  end

  test "requires child profile" do
    book = Book.new(title: "Test Book")
    assert_not book.valid?
  end

  test "status defaults to draft" do
    book = Book.create!(title: "Test Book", child_profile: @child_profile)
    assert_equal "draft", book.status
  end

  test "status can be set to published" do
    book = Book.create!(title: "Test Book", status: "published", child_profile: @child_profile)
    assert_equal "published", book.status
  end

  test "status must be valid" do
    book = Book.new(title: "Test Book", child_profile: @child_profile)
    assert_raises(ArgumentError) do
      book.status = "invalid_status"
    end
  end

  test "has many drawings" do
    book = Book.create!(title: "Test Book", child_profile: @child_profile)
    assert_respond_to book, :drawings
    assert_equal 0, book.drawings.count
  end

  test "destroys dependent drawings" do
    book = Book.create!(title: "Test Book", child_profile: @child_profile)
    drawing = book.drawings.create!(position: 0)
    drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg")

    assert_difference "Drawing.count", -1 do
      book.destroy
    end
  end

  test "belongs to child profile" do
    book = Book.create!(title: "Test Book", child_profile: @child_profile)
    assert_equal @child_profile, book.child_profile
  end

  test "recent scope orders by created_at desc" do
    book1 = Book.create!(title: "First Book", child_profile: @child_profile, created_at: 2.days.ago)
    book2 = Book.create!(title: "Second Book", child_profile: @child_profile, created_at: 1.day.ago)

    assert_equal [ book2, book1 ], Book.recent.to_a
  end

  test "published scope returns only published books" do
    draft_book = Book.create!(title: "Draft Book", status: "draft", child_profile: @child_profile)
    published_book = Book.create!(title: "Published Book", status: "published", child_profile: @child_profile)

    assert_equal [ published_book ], Book.published.to_a
  end

  test "drafts scope returns only draft books" do
    draft_book = Book.create!(title: "Draft Book", status: "draft", child_profile: @child_profile)
    published_book = Book.create!(title: "Published Book", status: "published", child_profile: @child_profile)

    assert_equal [ draft_book ], Book.drafts.to_a
  end
end
