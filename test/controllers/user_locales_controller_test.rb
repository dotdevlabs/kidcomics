require "test_helper"

class UserLocalesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update_column(:locale, nil)
    log_in_as @user
  end

  test "valid locale updates user locale and redirects" do
    post user_locale_url, params: { locale: "fr" }
    assert_redirected_to root_path
    assert_equal "fr", @user.reload.locale
  end

  test "another valid locale updates user locale" do
    post user_locale_url, params: { locale: "pt-BR" }
    assert_redirected_to root_path
    assert_equal "pt-BR", @user.reload.locale
  end

  test "invalid locale is ignored and user locale unchanged" do
    post user_locale_url, params: { locale: "zz" }
    assert_redirected_to root_path
    assert_nil @user.reload.locale
  end

  test "requires authentication" do
    delete logout_url
    post user_locale_url, params: { locale: "fr" }
    assert_redirected_to login_path
  end
end
