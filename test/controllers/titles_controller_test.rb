require 'test_helper'

class Admin::TitlesControllerTest < ActionController::TestCase
  setup do
    @title = titles(:consultant)
  end

  test 'should get index' do
    get :index, nil, current_user_id: employees(:sys_admin).id
    assert_response :success
    assert_not_nil assigns(:titles)
  end

  test 'should get new' do
    get :new, nil, current_user_id: employees(:sys_admin).id
    assert_response :success
  end

  test 'should create title' do
    assert_difference('Title.count') do
      post :create, { title: { name: "#{@title.name} testing" } }, current_user_id: employees(:sys_admin).id
    end

    assert_redirected_to admin_titles_path
  end

  test 'should get edit' do
    get :edit, { id: @title }, current_user_id: employees(:sys_admin).id
    assert_response :success
  end

  test 'should update title' do
    patch :update, { id: @title, title: { name: @title.name } }, current_user_id: employees(:sys_admin).id
    assert_redirected_to admin_titles_path(assigns(:title))
  end

  test 'should destroy title' do
    assert_difference('Title.count', -1) do
      delete :destroy, { id: @title }, current_user_id: employees(:sys_admin).id
    end

    assert_redirected_to admin_titles_path
  end
end
