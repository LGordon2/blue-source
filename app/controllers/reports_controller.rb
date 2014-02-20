class ReportsController < ApplicationController
  before_action :require_login
  before_action :set_report, only: [:show, :destroy, :edit, :update]
  before_action :get_all_data, only: :show
  
  helper_method :employee_associations
  
  def edit
  end
  
  def index
    @reports = Report.where(employee: current_user)
  end
  
  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to reports_path(@report), flash: {success: "Report successfully updated."} }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_report_path(@report), flash: {error: @report.errors.full_messages} }
        format.json { render json: reports_path(@report).errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url, flash: {success: "Report successfully deleted."} }
      format.json { head :no_content }
    end
  end
  
  def new
    @report = Report.new
  end
  
  def show
    @keys =  @report.query_data.collect {|r| r["column_name"] if r["show"] }.compact
  end
  
  def stuff
    respond_to do |format|
      format.js
    end
  end
  
  def fix_select
    respond_to do |format|
      format.js
    end
  end
  
  def create
    report = Report.new(report_params)
    if report.save
      redirect_to reports_path
    else
      redirect_to new_report_path, flash: {error: report.errors.full_messages}
    end
  end
  
  def employee_associations
    ["Projects", "Departments"]
  end
  
  private
  def set_report
    @report = Report.find(params[:id])
  end
  
  def report_params
    params.require(:report).permit(:name, query_data: [:column_name, :operator, :text, :show]).merge("employee_id" => current_user.id)
  end
  
  def get_all_data
    @table_data = Employee.all
    @report.query_data.each do |data|
      column_name = data["column_name"]
      text = data["text"]
      if data["column_name"].in? employee_associations
        column_name = data["column_name"].downcase.singularize + "_id"
      elsif data["column_name"] == "Employee Name"
        column_name = "display_name"
      end
      
      case data['operator'].downcase
      when "equals"
        @table_data = @table_data.report_equals(column_name, text)
      when "less_than"
        @table_data = @table_data.report_less_than(column_name, text)
      when "greater_than"
        @table_data = @table_data.report_greater_than(column_name, text)
      when "less_than_or_equal"
        @table_data = @table_data.report_less_than_or_equal(column_name, text)
      when "greater_than_or_equal"
        @table_data = @table_data.report_greater_than_or_equal(column_name, text)
      when "nil"
        @table_data = @table_data.report_nil(column_name)
      end
    end
  end
end
