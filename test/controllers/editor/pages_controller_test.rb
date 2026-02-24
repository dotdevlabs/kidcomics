require "test_helper"

class Editor::PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    @child_profile = ChildProfile.create!(name: "Test Child", age: 8, family_account: @family_account)
    @book = Book.create!(
      title: "Test Book",
      child_profile: @child_profile,
      edit_mode: "shared"
    )
    @image = fixture_file_upload("test_image.png", "image/png")
    @page = @book.drawings.create!(
      position: 0,
      image: @image
    )
    # Set up session for authentication
    post login_url, params: { email: @user.email, password: "password123" }
  end

  test "should create page" do
    assert_difference("Drawing.count") do
      post editor_child_profile_book_pages_url(@child_profile, @book),
           params: { narration_text: "Once upon a time" }
    end

    assert_redirected_to edit_editor_child_profile_book_path(@child_profile, @book)
  end

  test "should update page text" do
    patch editor_child_profile_book_page_url(@child_profile, @book, @page),
          params: { page: { narration_text: "Updated narration", dialogue_text: "Updated dialogue" } }

    @page.reload
    assert_equal "Updated narration", @page.narration_text
    assert_equal "Updated dialogue", @page.dialogue_text
  end

  test "should update page via json" do
    patch editor_child_profile_book_page_url(@child_profile, @book, @page),
          params: { page: { narration_text: "JSON update" } },
          as: :json

    assert_response :success
    @page.reload
    assert_equal "JSON update", @page.narration_text
  end

  test "should destroy page" do
    assert_difference("Drawing.count", -1) do
      delete editor_child_profile_book_page_url(@child_profile, @book, @page)
    end

    assert_redirected_to edit_editor_child_profile_book_path(@child_profile, @book)
  end

  test "should reorder pages" do
    page2 = @book.drawings.create!(position: 1, image: @image)
    page3 = @book.drawings.create!(position: 2, image: @image)

    # Move page3 to position 0
    patch reorder_editor_child_profile_book_page_url(@child_profile, @book, page3),
          params: { position: 0 },
          as: :json

    assert_response :success
    page3.reload
    assert_equal 0, page3.position
  end

  test "should not allow creating page beyond onboarding limit" do
    @book.update!(is_onboarding_book: true)

    # Create 5 pages (onboarding limit)
    5.times do |i|
      @book.drawings.create!(position: i, image: @image)
    end

    # Try to create 6th page
    assert_no_difference("Drawing.count") do
      post editor_child_profile_book_pages_url(@child_profile, @book),
           params: { narration_text: "Should not create" }
    end
  end
end
