class ReportsController < ApplicationController
  before_action :require_login
  before_action :set_report, only: :show
  
  def index
  end
  
  def new
    
  end
  
  def show
  end
  
  def create
    report = Report.new(report_params)
    if report.save
      redirect_to reports_path
    else
      redirect_to new_report_path
    end
  end
  
  private
  def set_report
    @report = Report.find(params[:id])
  end
  
  def report_params
    params.require(:report).permit(:column_name, :operator, :text)
  end
end
