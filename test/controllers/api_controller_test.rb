# rubocop:disable Style/LineLength, Style/ClassLength
require 'test_helper'

# Testing that API controller is ok.
class ApiControllerTest < ActionController::TestCase
  setup do
    user_file = File.join(Rails.root, 'config', 'api.yml')
    assert File.exist?(user_file), "Users file doesn't exist."
    @users = YAML.load_file(user_file)
    assert_not_empty @users
  end

  test 'should not get subordinates with no login' do
    get :subordinates, params_with_user
    assert_response 401
  end

  test 'should not get manager with no login' do
    get :manager, params_with_user
    assert_response 401
  end

  test 'should not get subordinates with no login even if logged in' do
    get :subordinates, params_with_user, current_user_id: employees(:consultant)
    assert_response 401
  end

  test 'should not get manager with no login even if logged in' do
    get :manager, params_with_user, current_user_id: employees(:consultant)
    assert_response 401
  end

  test 'should get subordinates with valid login' do
    @request.headers['Authorization'] = "Basic #{get_valid_encoded_string(@users.first)}"
    get :subordinates, params_with_user
    assert_response :success
  end

  test 'should get manager with valid login' do
    @request.headers['Authorization'] = "Basic #{get_valid_encoded_string(@users.first)}"
    get :manager, params_with_user
    assert_response :success
  end

  test 'should get subordinates with valid login even if logged in' do
    @request.headers['Authorization'] = "Basic #{get_valid_encoded_string(@users.first)}"
    get :subordinates, params_with_user, current_user_id: employees(:consultant)
    assert_response :success
  end

  test 'should get manager with valid login even if logged in' do
    @request.headers['Authorization'] = "Basic #{get_valid_encoded_string(@users.first)}"
    get :manager, params_with_user, current_user_id: employees(:consultant)
    assert_response :success
  end

  test 'should not get subordinates with invalid login' do
    @request.headers['Authorization'] = "Basic #{get_invalid_encoded_string(@users.first)}"
    get :subordinates, params_with_user
    assert_response 401
  end

  test 'should not get manager with invalid login' do
    @request.headers['Authorization'] = "Basic #{get_invalid_encoded_string(@users.first)}"
    get :manager, params_with_user
    assert_response 401
  end

  test 'should not get subordinates with invalid login even if logged in' do
    @request.headers['Authorization'] = "Basic #{get_invalid_encoded_string(@users.first)}"
    get :subordinates, params_with_user, current_user_id: employees(:consultant)
    assert_response 401
  end

  test 'should not get manager with invalid login even if logged in' do
    @request.headers['Authorization'] = "Basic #{get_invalid_encoded_string(@users.first)}"
    get :manager, params_with_user, current_user_id: employees(:consultant)
    assert_response 401
  end

  test 'should get subordinates with valid login with errors if no employee' do
    @request.headers['Authorization'] = "Basic #{get_valid_encoded_string(@users.first)}"
    get :subordinates, params_without_user, current_user_id: employees(:consultant)
    assert_response :success
    assert_not_empty JSON.parse(@response.body)['errors']
  end

  test 'should get manager with valid login with errors if no employee' do
    @request.headers['Authorization'] = "Basic #{get_valid_encoded_string(@users.first)}"
    get :manager, params_without_user, current_user_id: employees(:consultant)
    assert_response :success
    assert_not_empty JSON.parse(@response.body)['errors']
  end

  test 'should get subordinates with valid login with errors if unknown employee' do
    @request.headers['Authorization'] = "Basic #{get_valid_encoded_string(@users.first)}"
    get :subordinates, params_with_unknown_user, current_user_id: employees(:consultant)
    assert_response :success
    assert_not_empty JSON.parse(@response.body)['error']
  end

  test 'should get manager with valid login with errors if unknown employee' do
    @request.headers['Authorization'] = "Basic #{get_valid_encoded_string(@users.first)}"
    get :manager, params_with_unknown_user, current_user_id: employees(:consultant)
    assert_response :success
    assert_not_empty JSON.parse(@response.body)['error']
  end

  test 'should not exception for manager with valid login if employee does not have manager' do
    @request.headers['Authorization'] = "Basic #{get_valid_encoded_string(@users.first)}"
    assert employees(:director).manager.blank?
    assert_nothing_raised do
      get :manager, params_with_user(:director), current_user_id: employees(:consultant)
    end
    assert_response :success
  end

  test 'subordinates must not contain self' do
    @request.headers['Authorization'] = "Basic #{get_valid_encoded_string(@users.first)}"
    get :subordinates, format: :json, q: employees(:director).username
    assert_not response_includes_employee?(employees(:director)), 'Subordinates includes employee'
    assert_response :success
  end

  private

  def response_includes_employee?(employee, select = %w(username first_name last_name location))
    JSON.parse(@response.body).include?(employee.attributes.select { |k, _| k.in?(select) })
  end

  def get_valid_encoded_string(user)
    get_encoded_string(user)
  end

  def get_invalid_encoded_string(user)
    get_encoded_string(user, 'i am evil')
  end

  def get_encoded_string(user, inserted_string = nil)
    Base64.encode64("#{user['username']}#{inserted_string}:#{user['password']}").chomp
  end

  def params_with_user(symbol = :consultant)
    { format: :json, q: employees(symbol).username }
  end

  def params_with_unknown_user
    { format: :json, q: "#{employees(:consultant).username}1234x" }
  end

  def params_without_user
    { format: :json }
  end
end
