require "test_helper"

class QuotesControllerTest < ActionDispatch::IntegrationTest
  test "root route returns success status" do
    get root_url
    assert_response :success
  end

  test "random action renders a quote when quotes exist" do
    get root_url
    assert_response :success
    assert_select "p", text: /Holy/
  end

  test "random action handles gracefully when no quotes exist" do
    Quote.destroy_all
    get root_url
    assert_response :not_found
    assert_match /No quotes available/, response.body
  end
end
