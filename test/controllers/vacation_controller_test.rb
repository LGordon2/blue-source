require 'test_helper'

class VacationControllerTest < ActionController::TestCase
  test "should not get new if user not logged in" do
    get :new
    assert_redirected_to :login
  end

end
