class VacationController < ApplicationController
  before_action :require_manager_login
  before_action :set_vacation, only: [:destroy, :update]
  
  def new
    @vacation = Vacation.new(vacation_params)
    respond_to do |format|
      if @vacation.save
        format.html {redirect_to :back, flash: {notice: "Time off successfully saved.", created: true}}
      else
        format.html{redirect_to :back, flash: {error: @vacation.errors.full_messages}}
      end
    end
  end
  
  def update
    respond_to do |format|
      if @vacation.update(vacation_params)
        format.html {redirect_to :back, flash: {notice: "Time off successfully updated.", created: true}}
      else
        format.html {redirect_to :back, flash: {error: @vacation.errors.full_messages}}
      end
    end
  end
  
  def destroy
    @vacation.destroy if current_user.above? @vacation.employee
    respond_to do |format|
      format.html{redirect_to :back, flash: {notice: "Vacation successfully deleted."}}
    end
  end
  
  def edit
    
  end
  
  private
  
  def set_vacation
    @vacation = Vacation.find(params[:id])
  end
  
  def vacation_params
    params.require(:vacation).permit(:date_requested,:start_date,:end_date,:vacation_type,:business_days,:manager_id,:employee_id)
  end 
end
