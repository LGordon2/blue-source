require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  test "should not get all if not logged in" do
    get :index
    assert_redirected_to :login
  end
  
  test "should not get all if consultant" do
    get :index, nil, session = {current_user_id: employees(:consultant).id}
    assert_redirected_to view_employee_vacations_path(employees(:consultant))
  end

  test "manager can view projects" do
    get :index, {format: :json}, session = {current_user_id: employees(:manager).id}
    assert_response :success
  end
  
  test "director can view projects" do
    get :index, {format: :json}, session = {current_user_id: employees(:upper_manager).id}
    assert_response :success
  end
end
