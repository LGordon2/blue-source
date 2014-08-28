require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  def setup
    @consultant = employees(:consultant)
    @consultant2 = employees(:consultant2)
    @manager = employees(:manager)
    @upper_manager = employees(:upper_manager)
    @project1 = projects(:one)
  end

  test 'should not get all if not logged in' do
    get :index
    assert_redirected_to :login
  end

  test 'should not get all if consultant' do
    get :index, nil, current_user_id: @consultant.id
    assert_redirected_to view_employee_vacations_path(@consultant)
  end

  test 'manager can view projects' do
    get :index, { format: :json }, current_user_id: @manager.id
    assert_response :success
  end

  test 'director can view projects' do
    get :index, { format: :json }, current_user_id: @upper_manager.id
    assert_response :success
  end

  test 'manager should be able to view a project' do
    get :show, { id: @project1.id }, current_user_id: @manager.id
    assert_response :success
  end

  test 'manager should be able to view the leads for a project' do
    get :leads, { project_id: @project1.id, format: :json }, current_user_id: @manager.id
    assert_response :success
  end

  test 'upper manager should be able to create a project' do
    request.env['HTTP_REFERER'] = projects_path
    post :create, { project: {name: 'The Project'} }, current_user_id: @upper_manager.id
    assert_nil flash[:error]
  end

  test 'cannot create a project with start date after end date' do
    request.env['HTTP_REFERER'] = projects_path
    post :create, { project: {name: 'The Project', start_date: Time.now + 1.day, end_date: Time.now} }, current_user_id: @upper_manager.id
    assert_not_nil flash[:error]
  end

  test 'consultant cannot create projects' do
    request.env['HTTP_REFERER'] = projects_path
    prev_project_count = Project.count
    post :create, { project: {name: 'The Project', start_date: Time.now, end_date: Time.now + 1.day} }, current_user_id: @consultant.id
    assert_equal prev_project_count, Project.count
  end

  test 'regular manager cannot create projects' do
    request.env['HTTP_REFERER'] = projects_path
    prev_project_count = Project.count
    post :create, { project: {name: 'The Project', start_date: Time.now, end_date: Time.now + 1.day} }, current_user_id: @manager.id
    assert_not_nil flash[:error]
    assert_equal prev_project_count, Project.count
  end

  test 'can update leads on a project' do
    assert_includes @project1.leads, @consultant
    assert_not_includes @project1.leads, @consultant2
    patch :update, { id: @project1.id, project: {name: 'The Project', start_date: Time.now, end_date: Time.now + 1.day, leads: [@consultant2.id]} }, current_user_id: @upper_manager.id
    assert_not_includes @project1.leads, @consultant
    assert_includes @project1.leads, @consultant2
  end

  test 'cannot update project to have start date after end date' do
    request.env['HTTP_REFERER'] = projects_path
    patch :update, { id: @project1.id, project: {name: 'The Project', start_date: Time.now + 1.day, end_date: Time.now } }, current_user_id: @upper_manager.id
    assert_not_nil flash[:error]
  end
end
