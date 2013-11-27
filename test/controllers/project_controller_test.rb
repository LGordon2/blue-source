require 'test_helper'

class ProjectControllerTest < ActionController::TestCase
  test "should not get all if not logged in" do
    get :all
    assert_redirected_to :login
  end
  
  test "should not get all if consultant" do
    get :all, nil, session = {current_user_id: employees(:consultant).id}
    assert_redirected_to :sorry
  end

  test "manager can view projects" do
    get :all, {format: :json}, session = {current_user_id: employees(:manager).id}
    assert_response :success
  end
  
  test "director can view projects" do
    get :all, {format: :json}, session = {current_user_id: employees(:director).id}
    assert_response :success
  end
end
