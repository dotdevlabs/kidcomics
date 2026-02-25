require "test_helper"

class Editor::BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    @child_profile = ChildProfile.create!(name: "Test Child", age: 8, family_account: @family_account)
    @book = Book.create!(
      title: "Test Book",
      child_profile: @child_profile,
      edit_mode: "shared"
    )
    # Set up session for authentication
    post login_url, params: { email: @user.email, password: "password123" }
  end

  test "should get edit" do
    get edit_editor_child_profile_book_url(@child_profile, @book)
    assert_response :success
  end

  test "should update book" do
    patch editor_child_profile_book_url(@child_profile, @book),
          params: { book: { title: "Updated Title", dedication: "For my child", edit_mode: "parent_only" } }

    @book.reload
    assert_equal "Updated Title", @book.title
    assert_equal "For my child", @book.dedication
    assert_equal "parent_only", @book.edit_mode
    assert_not_nil @book.last_edited_at
  end


  test "should validate edit mode" do
    patch editor_child_profile_book_url(@child_profile, @book),
          params: { book: { edit_mode: "invalid_mode" } }

    assert_response :unprocessable_entity
  end
end
