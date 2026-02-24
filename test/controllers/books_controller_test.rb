require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    @child_profile = ChildProfile.create!(name: "Test Child", age: 8, family_account: @family_account)
    @book = Book.create!(title: "Test Book", child_profile: @child_profile)
  end

  test "should get index" do
    get child_profile_books_url(@child_profile)
    assert_response :success
  end

  test "should get new" do
    get new_child_profile_book_url(@child_profile)
    assert_response :success
  end

  test "should create book" do
    assert_difference("Book.count") do
      post child_profile_books_url(@child_profile), params: { book: { title: "New Book", description: "A new book" } }
    end

    assert_redirected_to child_profile_book_url(@child_profile, Book.last)
  end

  test "should show book" do
    get child_profile_book_url(@child_profile, @book)
    assert_response :success
  end

  test "should get edit" do
    get edit_child_profile_book_url(@child_profile, @book)
    assert_response :success
  end

  test "should update book" do
    patch child_profile_book_url(@child_profile, @book), params: { book: { title: "Updated Title" } }
    assert_redirected_to child_profile_book_url(@child_profile, @book)

    @book.reload
    assert_equal "Updated Title", @book.title
  end

  test "should destroy book" do
    assert_difference("Book.count", -1) do
      delete child_profile_book_url(@child_profile, @book)
    end

    assert_redirected_to child_profile_books_url(@child_profile)
  end
end
