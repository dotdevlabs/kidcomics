require "test_helper"

class ChildProfileTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = FamilyAccount.create!(name: "Test Family", owner: @user)
  end

  test "valid child profile" do
    child_profile = ChildProfile.new(name: "Test Child", age: 8, family_account: @family_account)
    assert child_profile.valid?
  end

  test "requires name" do
    child_profile = ChildProfile.new(age: 8, family_account: @family_account)
    assert_not child_profile.valid?
    assert_includes child_profile.errors[:name], "can't be blank"
  end

  test "requires age" do
    child_profile = ChildProfile.new(name: "Test Child", family_account: @family_account)
    assert_not child_profile.valid?
    assert_includes child_profile.errors[:age], "can't be blank"
  end

  test "age must be between 1 and 18" do
    child_profile = ChildProfile.new(name: "Test Child", age: 0, family_account: @family_account)
    assert_not child_profile.valid?

    child_profile.age = 19
    assert_not child_profile.valid?

    child_profile.age = 10
    assert child_profile.valid?
  end

  test "age_group returns :young for ages 0-6" do
    child_profile = ChildProfile.create!(name: "Young Child", age: 5, family_account: @family_account)
    assert_equal :young, child_profile.age_group
  end

  test "age_group returns :middle for ages 7-12" do
    child_profile = ChildProfile.create!(name: "Middle Child", age: 10, family_account: @family_account)
    assert_equal :middle, child_profile.age_group
  end

  test "age_group returns :teen for ages 13+" do
    child_profile = ChildProfile.create!(name: "Teen Child", age: 15, family_account: @family_account)
    assert_equal :teen, child_profile.age_group
  end

  test "belongs to family account" do
    child_profile = ChildProfile.create!(name: "Test Child", age: 8, family_account: @family_account)
    assert_equal @family_account, child_profile.family_account
  end

  test "book_statistics returns correct statistics" do
    child_profile = ChildProfile.create!(name: "Test Child", age: 8, family_account: @family_account)
    Book.create!(title: "Draft Book 1", status: "draft", child_profile: child_profile)
    Book.create!(title: "Draft Book 2", status: "draft", child_profile: child_profile)
    Book.create!(title: "Published Book", status: "published", child_profile: child_profile)
    Book.create!(title: "Favorite Book", status: "draft", favorited: true, child_profile: child_profile, view_count: 10)
    Book.create!(title: "Popular Book", status: "draft", view_count: 20, child_profile: child_profile)

    stats = child_profile.book_statistics

    assert_equal 5, stats[:total]
    assert_equal 4, stats[:drafts]
    assert_equal 1, stats[:published]
    assert_equal 1, stats[:favorites]
    assert_equal 30, stats[:total_views]
  end
end
