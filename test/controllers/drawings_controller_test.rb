require "test_helper"

class DrawingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    @child_profile = ChildProfile.create!(name: "Test Child", age: 8, family_account: @family_account)
    @book = Book.create!(title: "Test Book", child_profile: @child_profile)
    @drawing = Drawing.create!(book: @book, position: 0)
    @drawing.image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test_image.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    log_in_as(@user)
  end

  test "should get index" do
    get child_profile_book_drawings_url(@child_profile, @book)
    assert_response :success
  end

  test "should get new" do
    get new_child_profile_book_drawing_url(@child_profile, @book)
    assert_response :success
  end

  test "should create drawing with image" do
    file = fixture_file_upload(Rails.root.join("test", "fixtures", "files", "test_image.jpg"), "image/jpeg")

    assert_difference("Drawing.count") do
      post child_profile_book_drawings_url(@child_profile, @book), params: {
        drawing: {
          images: [ file ],
          tag: "character"
        }
      }
    end

    assert_redirected_to child_profile_book_drawings_url(@child_profile, @book)
  end

  test "should get edit" do
    get edit_child_profile_book_drawing_url(@child_profile, @book, @drawing)
    assert_response :success
  end

  test "should update drawing" do
    patch child_profile_book_drawing_url(@child_profile, @book, @drawing), params: {
      drawing: {
        caption: "Updated caption",
        tag: "background"
      }
    }

    assert_redirected_to child_profile_book_drawings_url(@child_profile, @book)

    @drawing.reload
    assert_equal "Updated caption", @drawing.caption
    assert_equal "background", @drawing.tag
  end

  test "should destroy drawing" do
    assert_difference("Drawing.count", -1) do
      delete child_profile_book_drawing_url(@child_profile, @book, @drawing)
    end

    assert_redirected_to child_profile_book_drawings_url(@child_profile, @book)
  end
end
