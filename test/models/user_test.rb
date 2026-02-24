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
end
