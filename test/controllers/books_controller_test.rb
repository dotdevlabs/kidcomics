require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    @child_profile = ChildProfile.create!(name: "Test Child", age: 8, family_account: @family_account)
    @book = Book.create!(title: "Test Book", child_profile: @child_profile)
    log_in_as(@user)
  end

  test "should get index" do
    get child_profile_books_url(@child_profile)
    assert_response :success
  end

  test "should get new and redirect to photo upload" do
    assert_difference("Book.count") do
      get new_child_profile_book_url(@child_profile)
    end

    # Photo-first approach: auto-creates book and redirects to drawing upload
    new_book = Book.last
    assert_redirected_to new_child_profile_book_drawing_url(@child_profile, new_book)
  end

  test "should create book and redirect to new action" do
    # Create action is deprecated, redirects to new which handles auto-creation
    post child_profile_books_url(@child_profile), params: { book: { title: "New Book", description: "A new book" } }
    assert_redirected_to new_child_profile_book_url(@child_profile)
  end

  test "should show book" do
    get child_profile_book_url(@child_profile, @book)
    assert_response :success
  end

  test "should get edit and redirect to AI editor" do
    get edit_child_profile_book_url(@child_profile, @book)
    # All editing now happens through the AI-powered editor
    assert_redirected_to edit_editor_child_profile_book_url(@child_profile, @book)
  end

  test "should update book and redirect to AI editor" do
    patch child_profile_book_url(@child_profile, @book), params: { book: { title: "Updated Title" } }
    # Updates now happen through the AI-powered editor
    assert_redirected_to edit_editor_child_profile_book_url(@child_profile, @book)

    # Book should not be updated via this route
    @book.reload
    assert_not_equal "Updated Title", @book.title
  end

  test "should destroy book" do
    assert_difference("Book.count", -1) do
      delete child_profile_book_url(@child_profile, @book)
    end

    assert_redirected_to child_profile_books_url(@child_profile)
  end

  # Bookshelf feature tests
  test "index should filter by status" do
    draft_book = Book.create!(title: "Draft Book", status: "draft", child_profile: @child_profile)
    published_book = Book.create!(title: "Published Book", status: "published", child_profile: @child_profile)

    get child_profile_books_url(@child_profile, status: "published")
    assert_response :success
    assert_select "h3", text: "Published Book"
    assert_select "h3", { text: "Draft Book", count: 0 }
  end

  test "index should search by title" do
    book1 = Book.create!(title: "Amazing Spider-Man", child_profile: @child_profile)
    book2 = Book.create!(title: "Batman Adventures", child_profile: @child_profile)

    get child_profile_books_url(@child_profile, search: "spider")
    assert_response :success
    assert_select "h3", text: "Amazing Spider-Man"
    assert_select "h3", { text: "Batman Adventures", count: 0 }
  end

  test "index should sort by title" do
    get child_profile_books_url(@child_profile, sort: "title")
    assert_response :success
  end

  test "index should sort by popularity" do
    get child_profile_books_url(@child_profile, sort: "popularity")
    assert_response :success
  end

  test "index should filter by favorited" do
    favorited_book = Book.create!(title: "Favorite Book", child_profile: @child_profile, favorited: true)

    get child_profile_books_url(@child_profile, favorited: "true")
    assert_response :success
  end

  test "toggle_favorite should toggle book favorite status" do
    assert_equal false, @book.favorited

    patch toggle_favorite_child_profile_book_url(@child_profile, @book)
    @book.reload
    assert_equal true, @book.favorited

    patch toggle_favorite_child_profile_book_url(@child_profile, @book)
    @book.reload
    assert_equal false, @book.favorited
  end

  test "show should increment view count" do
    initial_count = @book.view_count

    get child_profile_book_url(@child_profile, @book)
    @book.reload

    assert_equal initial_count + 1, @book.view_count
  end

  test "index should display statistics" do
    Book.create!(title: "Draft Book", status: "draft", child_profile: @child_profile)
    Book.create!(title: "Published Book", status: "published", child_profile: @child_profile)
    Book.create!(title: "Favorite Book", favorited: true, child_profile: @child_profile)

    get child_profile_books_url(@child_profile)
    assert_response :success
    assert_select ".text-gray-600", text: "Total Books"
  end
end
