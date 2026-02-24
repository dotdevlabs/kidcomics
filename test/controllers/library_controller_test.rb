require "test_helper"

class LibraryControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    @child_profile1 = ChildProfile.create!(name: "Child One", age: 8, family_account: @family_account)
    @child_profile2 = ChildProfile.create!(name: "Child Two", age: 10, family_account: @family_account)
    @book1 = Book.create!(title: "Book One", child_profile: @child_profile1)
    @book2 = Book.create!(title: "Book Two", child_profile: @child_profile2)

    # Simulate logged-in user
    post login_url, params: { email: @user.email, password: "password123" }
  end

  test "should get index" do
    get library_url
    assert_response :success
  end

  test "index should display books from all child profiles" do
    get library_url
    assert_response :success
    assert_select "h3", text: "Book One"
    assert_select "h3", text: "Book Two"
  end

  test "index should filter by child profile" do
    get library_url(child_profile_id: @child_profile1.id)
    assert_response :success
    assert_select "h3", text: "Book One"
    assert_select "h3", { text: "Book Two", count: 0 }
  end

  test "index should filter by status" do
    draft_book = Book.create!(title: "Draft Book", status: "draft", child_profile: @child_profile1)
    published_book = Book.create!(title: "Published Book", status: "published", child_profile: @child_profile1)

    get library_url(status: "published")
    assert_response :success
    assert_select "h3", text: "Published Book"
    assert_select "h3", { text: "Draft Book", count: 0 }
  end

  test "index should search by title" do
    get library_url(search: "Book One")
    assert_response :success
    assert_select "h3", text: "Book One"
    assert_select "h3", { text: "Book Two", count: 0 }
  end

  test "index should sort books" do
    get library_url(sort: "title")
    assert_response :success

    get library_url(sort: "popularity")
    assert_response :success

    get library_url(sort: "oldest")
    assert_response :success
  end

  test "index should display family statistics" do
    Book.create!(title: "Draft Book", status: "draft", child_profile: @child_profile1)
    Book.create!(title: "Published Book", status: "published", child_profile: @child_profile2)

    get library_url
    assert_response :success
    assert_select ".text-gray-600", text: "Total Books"
  end

  test "index should redirect if user has no family account" do
    # Create a user without a family account
    user_without_family = User.create!(name: "No Family User", email: "nofamily@example.com", password: "password123")

    # Logout current user
    delete logout_url

    # Login as user without family
    post login_url, params: { email: user_without_family.email, password: "password123" }

    get library_url
    assert_redirected_to root_path
    assert_equal "You must have a family account to access the library.", flash[:alert]
  end

  test "index should require login" do
    # Logout
    delete logout_url

    get library_url
    assert_redirected_to login_path
  end
end
