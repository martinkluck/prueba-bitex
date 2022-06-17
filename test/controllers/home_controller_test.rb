require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should can create" do
    post root_url, params: { email: 'example@example.com' }
    assert_response :success
  end
end
