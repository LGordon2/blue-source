require 'test_helper'

class ProjectHistoriesControllerTest < ActionController::TestCase
  def setup
    @manager = employees(:manager)
    @consultant = employees(:consultant)
    @consultant2 = employees(:consultant2)
    @consultant_history = project_histories(:consultant_history)
  end

  test 'index can be reached as a manager' do
    get :index, { employee_id: @consultant.id }, current_user_id: @manager.id
    assert_response :success, @response.headers
  end

  test 'index cannot be reached as a consultant' do
    get :index, { employee_id: @consultant.id }, current_user_id: @consultant.id
    assert_redirected_to :root, @response.headers
  end

  test 'index with non nil sort should not break' do
    get :index, { employee_id: @consultant.id, sort: 'project_name' }, current_user_id: @manager.id
    assert_response :success, @response.headers
  end

  test 'manager can create a new project history for consultant' do
    post :create, { employee_id: @consultant.id, new: { project_history: { roll_on_date: Time.now, roll_off_date: Time.now + 1.day, project_id: Project.first.id } } }, current_user_id: @manager.id
    assert_nil flash[:error]
  end

  test 'manager cannot create a new project history for consultant not under them' do
    post :create, { employee_id: @consultant2.id, new: { project_history: { roll_on_date: Time.now, roll_off_date: Time.now + 1.day, project_id: Project.first.id } } }, current_user_id: @manager.id
    assert_not_nil flash[:error]
  end

  test 'manager can update a new project history for consultant' do
    patch :update, { employee_id: @consultant.id, id: @consultant_history.id, "#{@consultant_history.id}" => { project_history: { roll_on_date: Time.now, roll_off_date: Time.now + 1.day, project_id: Project.first.id } } }, current_user_id: @manager.id
    assert_nil flash[:error]
  end

  test 'manager cannot update a new project history for consultant not under them' do
    patch :update, { employee_id: @consultant2.id, id: @consultant_history.id, "#{@consultant_history.id}" => { project_history: { roll_on_date: Time.now, roll_off_date: Time.now + 1.day, project_id: Project.first.id } } }, current_user_id: @manager.id
    assert_not_nil flash[:error]
  end

  test 'manager can delete a new project history for consultant' do
    delete :destroy, { employee_id: @consultant.id, id: @consultant_history.id }, current_user_id: @manager.id
    assert_nil flash[:error]
  end

  test 'manager cannot delete a new project history for consultant not under them' do
    delete :destroy, { employee_id: @consultant2.id, id: @consultant_history.id }, current_user_id: @manager.id
    assert_not_nil flash[:error]
  end

  test "manager can view their subordinates's project history" do
    get :show, { employee_id: @consultant.id, id: @consultant_history.id, format: :json }, current_user_id: @manager.id
    assert_response :success
  end

  test 'cannot create a new project history with a start date after end date' do
    post :create, { employee_id: @consultant.id, new: { project_history: { roll_on_date: Time.now + 1.day, roll_off_date: Time.now, project_id: Project.first.id } } }, current_user_id: @manager.id
    assert_not_nil flash[:error]
  end

  test 'cannot update a project history with a start date after end date' do
    patch :update, { employee_id: @consultant.id, id: @consultant_history.id, "#{@consultant_history.id}" => { project_history: { roll_on_date: Time.now + 1.day, roll_off_date: Time.now, project_id: Project.first.id } } }, current_user_id: @manager.id
    assert_not_nil flash[:error]
  end
end
