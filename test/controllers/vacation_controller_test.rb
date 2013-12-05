require 'test_helper'

class VacationControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

end
