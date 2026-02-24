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
end
