require 'test_helper'

class AppsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apps_show_url
    assert_response :success
  end

end
