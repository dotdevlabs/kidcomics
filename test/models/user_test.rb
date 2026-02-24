require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(name: "Test User", email: "test@example.com", password: "password123")
    assert user.valid?
  end

  test "requires name" do
    user = User.new(email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "requires email" do
    user = User.new(name: "Test User", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "requires unique email" do
    User.create!(name: "User One", email: "test@example.com", password: "password123")
    user = User.new(name: "User Two", email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "email is case insensitive" do
    User.create!(name: "User One", email: "TEST@EXAMPLE.COM", password: "password123")
    user = User.new(name: "User Two", email: "test@example.com", password: "password123")
    assert_not user.valid?
  end

  test "password must be at least 6 characters" do
    user = User.new(name: "Test User", email: "test@example.com", password: "short")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "has secure password" do
    user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    assert user.authenticate("password123")
    assert_not user.authenticate("wrongpassword")
  end

  test "can have a family account" do
    user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    family_account = user.create_family_account!(name: "Test Family")
    assert_equal family_account, user.family_account
  end

  test "user should have default role of user" do
    user = User.new(name: "Test", email: "newtest@example.com", password: "password123")
    assert_equal "user", user.role
    assert user.user?
    assert_not user.admin?
  end

  test "user can be admin" do
    user = User.create!(name: "Admin", email: "admin@example.com", password: "password123", role: :admin)
    assert_equal "admin", user.role
    assert user.admin?
    assert_not user.user?
  end

  test "admins scope returns only admins" do
    User.create!(name: "Admin", email: "admin1@example.com", password: "password123", role: :admin)
    User.create!(name: "User", email: "user1@example.com", password: "password123", role: :user)

    assert_equal 1, User.admins.count
    assert User.admins.all?(&:admin?)
  end

  test "regular_users scope returns only non-admin users" do
    User.create!(name: "Admin", email: "admin2@example.com", password: "password123", role: :admin)
    regular_count = User.regular_users.count
    User.create!(name: "User", email: "user2@example.com", password: "password123", role: :user)

    assert_equal regular_count + 1, User.regular_users.count
    assert User.regular_users.all?(&:user?)
  end
end
