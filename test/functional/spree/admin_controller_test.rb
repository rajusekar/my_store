require 'test_helper'

class Spree::AdminControllerTest < ActionController::TestCase
  test "should get shwcse" do
    get :shwcse
    assert_response :success
  end

end
