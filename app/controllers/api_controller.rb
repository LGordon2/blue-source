# rubocop:disable Style/LineLength
# Semi open API controller for BlueSource
class ApiController < ApplicationController
  before_action :initialize_errors_array
  before_action :set_employee
  before_action :load_users
  before_action :authenticate

  def subordinates
    render_json_or_error
  end

  def manager
    render_json_or_error
  end

  private

  def render_json_or_error
    respond_to do |format|
      if @employee
        format.json
      else
        format.json { render_error_json }
      end
    end
  end

  def initialize_errors_array
    @errors = []
  end

  def render_error_json
    render json: { 'error'.pluralize(@errors.length) => @errors }
  end

  def set_employee
    @employee = Employee.find_by(username: query_params[:q])
    @errors << 'Employee not found' unless @employee
  end

  def query_params
    @errors << "Query string 'q' is blank, this"\
      ' should be a BlueSource username.' if params[:q].blank?
    params.permit(:q)
  end

  def load_users
    @users = YAML.load_file(File.join(Rails.root, 'config', 'api.yml'))
  end

  def authenticate
    authenticate_or_request_with_http_basic('BlueSource') do |username, password|
      @users.include?('username' => username, 'password' => password)
    end
  end
end
