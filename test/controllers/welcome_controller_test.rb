require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "should redirect to sorry if consultant" do
    get :index, nil, {current_user_id: employees(:consultant).id}
    assert_redirected_to action: :sorry
  end
  
  test "should get index if manager" do
    get :index, nil, {current_user_id: employees(:manager).id}
    assert !employees(:manager).subordinates.empty?
    assert_response :success
  end
end
