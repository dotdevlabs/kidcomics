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

    # Only check books for this child profile
    recent_books = Book.where(child_profile: @child_profile).recent.to_a
    assert_equal [ book2, book1 ], recent_books
  end

  test "published scope returns only published books" do
    draft_book = Book.create!(title: "Draft Book", status: "draft", child_profile: @child_profile)
    published_book = Book.create!(title: "Published Book", status: "published", child_profile: @child_profile)

    assert_equal [ published_book ], Book.published.to_a
  end

  test "drafts scope returns only draft books" do
    draft_book = Book.create!(title: "Draft Book", status: "draft", child_profile: @child_profile)
    published_book = Book.create!(title: "Published Book", status: "published", child_profile: @child_profile)

    # Only check books for this child profile
    draft_books = Book.where(child_profile: @child_profile).drafts.to_a
    assert_equal [ draft_book ], draft_books
  end

  # Bookshelf feature tests
  test "favorited defaults to false" do
    book = Book.create!(title: "Test Book", child_profile: @child_profile)
    assert_equal false, book.favorited
  end

  test "view_count defaults to 0" do
    book = Book.create!(title: "Test Book", child_profile: @child_profile)
    assert_equal 0, book.view_count
  end

  test "increment_view_count! increments view count" do
    book = Book.create!(title: "Test Book", child_profile: @child_profile)
    assert_equal 0, book.view_count

    book.increment_view_count!
    assert_equal 1, book.view_count

    book.increment_view_count!
    assert_equal 2, book.view_count
  end

  test "toggle_favorite! toggles favorited status" do
    book = Book.create!(title: "Test Book", child_profile: @child_profile)
    assert_equal false, book.favorited

    book.toggle_favorite!
    assert_equal true, book.favorited

    book.toggle_favorite!
    assert_equal false, book.favorited
  end

  test "favorited scope returns only favorited books" do
    book1 = Book.create!(title: "Favorited Book", child_profile: @child_profile, favorited: true)
    book2 = Book.create!(title: "Regular Book", child_profile: @child_profile, favorited: false)

    assert_equal [ book1 ], Book.where(child_profile: @child_profile).favorited.to_a
  end

  test "search_by_title finds books by partial title" do
    book1 = Book.create!(title: "The Amazing Spider-Man", child_profile: @child_profile)
    book2 = Book.create!(title: "Batman Adventures", child_profile: @child_profile)
    book3 = Book.create!(title: "The Amazing Adventures", child_profile: @child_profile)

    results = Book.search_by_title("amazing").to_a
    assert_includes results, book1
    assert_includes results, book3
    assert_not_includes results, book2
  end

  test "search_by_title is case insensitive" do
    book = Book.create!(title: "The Amazing Spider-Man", child_profile: @child_profile)

    assert_includes Book.search_by_title("AMAZING").to_a, book
    assert_includes Book.search_by_title("amazing").to_a, book
    assert_includes Book.search_by_title("AmAzInG").to_a, book
  end

  test "oldest scope orders by created_at asc" do
    book1 = Book.create!(title: "First Book", child_profile: @child_profile, created_at: 2.days.ago)
    book2 = Book.create!(title: "Second Book", child_profile: @child_profile, created_at: 1.day.ago)

    oldest_books = Book.where(child_profile: @child_profile).oldest.to_a
    assert_equal [ book1, book2 ], oldest_books
  end

  test "by_title scope orders alphabetically" do
    book1 = Book.create!(title: "Zebra Book", child_profile: @child_profile)
    book2 = Book.create!(title: "Apple Book", child_profile: @child_profile)
    book3 = Book.create!(title: "Moon Book", child_profile: @child_profile)

    titled_books = Book.where(child_profile: @child_profile).by_title.to_a
    assert_equal [ book2, book3, book1 ], titled_books
  end

  test "by_popularity scope orders by view_count desc" do
    book1 = Book.create!(title: "Popular Book", child_profile: @child_profile, view_count: 100)
    book2 = Book.create!(title: "Less Popular Book", child_profile: @child_profile, view_count: 10)
    book3 = Book.create!(title: "Unpopular Book", child_profile: @child_profile, view_count: 1)

    popular_books = Book.where(child_profile: @child_profile).by_popularity.to_a
    assert_equal [ book1, book2, book3 ], popular_books
  end

  test "created_after scope filters books created after date" do
    old_book = Book.create!(title: "Old Book", child_profile: @child_profile, created_at: 5.days.ago)
    recent_book = Book.create!(title: "Recent Book", child_profile: @child_profile, created_at: 1.day.ago)

    filtered_books = Book.created_after(3.days.ago).to_a
    assert_includes filtered_books, recent_book
    assert_not_includes filtered_books, old_book
  end

  test "created_before scope filters books created before date" do
    old_book = Book.create!(title: "Old Book", child_profile: @child_profile, created_at: 5.days.ago)
    recent_book = Book.create!(title: "Recent Book", child_profile: @child_profile, created_at: 1.day.ago)

    filtered_books = Book.created_before(3.days.ago).to_a
    assert_includes filtered_books, old_book
    assert_not_includes filtered_books, recent_book
  end
end
