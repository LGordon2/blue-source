class ProjectHistoriesController < ApplicationController
  before_action :require_login

  #Sets the employee
  before_action :set_employee
  before_action :can_edit_employee

  before_action :set_project_history, only: [:show, :destroy, :update]

  def index
    @default_scheduled_hours_start = "8:30 AM"
    @default_scheduled_hours_end = "5:30 PM"
  end

  def create
    @project_history = ProjectHistory.new(project_history_params)
    if @project_history.save
      redirect_to employee_project_histories_path(@employee), flash: {success: "Project history successfully created."}
    else
      redirect_to employee_project_histories_path(@employee), flash: {error: @project_history.errors.full_messages}
    end
  end

  def update
    if @project_history.update(project_history_params)
      redirect_to employee_project_histories_path(@employee), flash: {success: "Project history successfully updated."}
    else
      redirect_to employee_project_histories_path(@employee), flash: {error: @project_history.errors.full_messages}
    end
  end

  def show
    respond_to do |format|
      format.json {render json: @project_history}
    end
  end

  def destroy
    if @project_history.destroy
      redirect_to employee_project_histories_path(@employee), flash: {success: "Project history successfully deleted."}
    else
      redirect_to employee_project_histories_path(@employee), flash: {error: @project_history.errors.full_messages}
    end
  end

  private

  def set_employee
    @employee ||= Employee.find(params[:employee_id])
  end

  def set_project_history
    @project_history ||= ProjectHistory.find(params[:id])
  end

  def project_history_params
    which_params = params[:id].blank? ? "new" : params[:id]
    params[which_params].require(:project_history).permit(:project_id,:lead_id,:roll_on_date,:roll_off_date,:scheduled_hours_start,:scheduled_hours_end,:memo).merge(employee_id: @employee.id)
  end

  def can_edit_employee
    redirect_to :root, flash: {error: "You do not have permission to edit this employee."} unless current_user.can_edit? @employee
  end
end
