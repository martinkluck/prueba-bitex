require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get root_url
    assert_response :success
  end

  test 'account should can create' do
    VCR.use_cassette('account_should_can_create') do
      post root_url, params: { email: 'example@example.com' }
      assert_response :success
    end
  end
end
