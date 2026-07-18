require "test_helper"

class ApplicationControllerLocaleTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update_column(:locale, nil)
  end

  test "valid locale param sets html lang attribute" do
    get login_url, params: { locale: "fr" }
    assert_select "html[lang=fr]"
  end

  test "invalid locale param falls back to default locale" do
    get login_url, params: { locale: "zz" }
    assert_select "html[lang=en]"
  end

  test "valid locale param persists to user when logged in" do
    log_in_as @user
    get dashboard_url, params: { locale: "es" }
    assert_equal "es", @user.reload.locale
  end

  test "invalid locale param does not update user locale" do
    log_in_as @user
    get dashboard_url, params: { locale: "zz" }
    assert_nil @user.reload.locale
  end

  test "user saved locale is used when no param given" do
    @user.update_column(:locale, "de")
    log_in_as @user
    get dashboard_url
    assert_select "html[lang=de]"
  end

  test "accept-language header sets locale for unauthenticated request" do
    get login_url, headers: { "HTTP_ACCEPT_LANGUAGE" => "it,en;q=0.9" }
    assert_select "html[lang=it]"
  end

  test "accept-language header with quality values picks highest available" do
    get login_url, headers: { "HTTP_ACCEPT_LANGUAGE" => "xx,fr;q=0.8,en;q=0.5" }
    assert_select "html[lang=fr]"
  end

  test "falls back to default locale when no signals present" do
    get login_url
    assert_select "html[lang=en]"
  end

  test "param locale takes precedence over user saved locale" do
    @user.update_column(:locale, "es")
    log_in_as @user
    get dashboard_url, params: { locale: "fr" }
    assert_select "html[lang=fr]"
    assert_equal "fr", @user.reload.locale
  end
end
