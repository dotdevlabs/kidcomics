require "test_helper"

class AdminActionTest < ActiveSupport::TestCase
  def setup
    @admin = User.create!(name: "Admin", email: "admin@test.com", password: "password123", role: :admin)
    @user = User.create!(name: "User", email: "user@test.com", password: "password123")
  end

  test "should create admin action with required fields" do
    action = AdminAction.create!(
      admin_user: @admin,
      action_type: "user_updated",
      target: @user,
      details: { field: "name" },
      ip_address: "127.0.0.1"
    )

    assert action.persisted?
    assert_equal @admin, action.admin_user
    assert_equal "user_updated", action.action_type
    assert_equal @user, action.target
  end

  test "should require admin_user_id" do
    action = AdminAction.new(action_type: "test_action")
    assert_not action.valid?
    assert_includes action.errors[:admin_user_id], "can't be blank"
  end

  test "should require action_type" do
    action = AdminAction.new(admin_user: @admin)
    assert_not action.valid?
    assert_includes action.errors[:action_type], "can't be blank"
  end

  test "log class method should create admin action" do
    action = AdminAction.log(
      admin: @admin,
      action: "test_action",
      target: @user,
      details: { test: "data" },
      ip: "192.168.1.1"
    )

    assert action.persisted?
    assert_equal @admin, action.admin_user
    assert_equal "test_action", action.action_type
    assert_equal @user, action.target
    assert_equal({ "test" => "data" }, action.details)
    assert_equal "192.168.1.1", action.ip_address
  end

  test "recent scope orders by created_at desc" do
    action1 = AdminAction.create!(admin_user: @admin, action_type: "action1")
    sleep 0.1
    action2 = AdminAction.create!(admin_user: @admin, action_type: "action2")

    recent_actions = AdminAction.recent
    assert_equal action2, recent_actions.first
    assert_equal action1, recent_actions.second
  end

  test "by_admin scope filters by admin_user_id" do
    another_admin = User.create!(name: "Admin2", email: "admin2@test.com", password: "password123", role: :admin)

    AdminAction.create!(admin_user: @admin, action_type: "action1")
    AdminAction.create!(admin_user: another_admin, action_type: "action2")

    assert_equal 1, AdminAction.by_admin(@admin.id).count
  end
end
