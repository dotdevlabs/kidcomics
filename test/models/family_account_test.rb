require "test_helper"

class FamilyAccountTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
  end

  test "valid family account" do
    family_account = FamilyAccount.new(name: "Test Family", owner: @user)
    assert family_account.valid?
  end

  test "requires name" do
    family_account = FamilyAccount.new(owner: @user)
    assert_not family_account.valid?
    assert_includes family_account.errors[:name], "can't be blank"
  end

  test "requires owner" do
    family_account = FamilyAccount.new(name: "Test Family")
    assert_not family_account.valid?
  end

  test "can have many child profiles" do
    family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    child1 = family_account.child_profiles.create!(name: "Child One", age: 8)
    child2 = family_account.child_profiles.create!(name: "Child Two", age: 12)

    assert_equal 2, family_account.child_profiles.count
    assert_includes family_account.child_profiles, child1
    assert_includes family_account.child_profiles, child2
  end

  test "deletes child profiles when deleted" do
    family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    family_account.child_profiles.create!(name: "Child One", age: 8)

    assert_difference "ChildProfile.count", -1 do
      family_account.destroy
    end
  end

  test "all_books returns books from all child profiles" do
    family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    child1 = family_account.child_profiles.create!(name: "Child One", age: 8)
    child2 = family_account.child_profiles.create!(name: "Child Two", age: 10)

    book1 = Book.create!(title: "Book One", child_profile: child1)
    book2 = Book.create!(title: "Book Two", child_profile: child2)
    book3 = Book.create!(title: "Book Three", child_profile: child1)

    all_books = family_account.all_books.to_a
    assert_equal 3, all_books.count
    assert_includes all_books, book1
    assert_includes all_books, book2
    assert_includes all_books, book3
  end

  test "family_book_statistics returns correct statistics" do
    family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
    child1 = family_account.child_profiles.create!(name: "Child One", age: 8)
    child2 = family_account.child_profiles.create!(name: "Child Two", age: 10)

    Book.create!(title: "Draft Book 1", status: "draft", child_profile: child1)
    Book.create!(title: "Draft Book 2", status: "draft", child_profile: child2)
    Book.create!(title: "Published Book 1", status: "published", child_profile: child1)
    Book.create!(title: "Published Book 2", status: "published", child_profile: child2)
    Book.create!(title: "Favorite Book", status: "draft", favorited: true, child_profile: child1, view_count: 15)
    Book.create!(title: "Popular Book", status: "draft", view_count: 25, child_profile: child2)

    stats = family_account.family_book_statistics

    assert_equal 6, stats[:total]
    assert_equal 4, stats[:drafts]
    assert_equal 2, stats[:published]
    assert_equal 1, stats[:favorites]
    assert_equal 40, stats[:total_views]
  end
end
