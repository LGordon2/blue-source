require 'test_helper'

class EmployeeControllerTest < ActionController::TestCase
  test "should get edit if manager of user" do
    get :edit, {id: employees(:consultant).id}, session = {current_user_id: employees(:manager).id}
    assert_response :success
  end
  
  test "should not be able to edit consultant if not consultant's manager" do
    get :edit, {id: employees(:consultant).id}, session = {current_user_id: employees(:manager2).id}
    assert_redirected_to controller: :welcome, action: :index
  end
  
  test "consultant should not get edit and should be redirected to sorry" do
    get :edit, {id: employees(:consultant).id}, session = {current_user_id: employees(:consultant).id}
    assert_redirected_to view_vacation_path(employees(:consultant))
  end
  
  test "consultant should not be able to edit other consultant and should be redirected to sorry" do
    get :edit, {id: employees(:consultant2).id}, session = {current_user_id: employees(:consultant).id}
    assert_redirected_to view_vacation_path(employees(:consultant))
  end
  
  test "should be able to view consultant if manager" do
    get :index, {id: employees(:consultant).id}, session = {current_user_id: employees(:manager).id}
    assert_response :success
  end
  
  test "should not be able to view consultant if not consultant's manager" do
    get :index, {id: employees(:consultant).id}, session = {current_user_id: employees(:manager2).id}
    assert_redirected_to controller: :welcome, action: :index
  end
  
  test "consultant should not be able to view consultant" do
    get :index, {id: employees(:consultant).id}, session = {current_user_id: employees(:consultant).id}
    assert_redirected_to view_vacation_path(employees(:consultant))
  end
  
  test "consultant should not be able to view other consultant" do
    get :index, {id: employees(:consultant2).id}, session = {current_user_id: employees(:consultant).id}
    assert_redirected_to view_vacation_path(employees(:consultant))
  end
  
  test "manager should be redirected to root when trying to manage own vacation" do
    manager = employees(:manager)
    get :vacation, {id: manager.id}, {current_user_id: manager}
    assert_redirected_to :root
  end
end
