class VacationController < ApplicationController
  before_action :require_manager_login
  before_action :set_vacation, only: [:destroy, :update]
  
  def new
    vacation = Vacation.create(vacation_params)
    if vacation.save
      redirect_to :back, flash: {notice: "Vacation successfully saved.", created: true}
    else
      redirect_to :back, flash: {error: vacation.errors.full_messages}
    end
  end
  
  def update
    if @vacation.update(vacation_params)
      redirect_to :back, flash: {notice: "Vacation successfully updated.", created: true}
    else
      redirect_to :back, flash: {error: @vacation.errors.full_messages}
    end
  end
  
  def destroy
    @vacation.destroy if current_user.above? @vacation.employee
    redirect_to :back, flash: {notice: "Vacation successfully deleted."}
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
