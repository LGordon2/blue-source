class VacationController < ApplicationController
  def new
    vacation = Vacation.create(vacation_params)
    vacation.employee_id = params[:id]
    if vacation.save
      redirect_to :back, flash: {notice: "Vacation successfully saved."}
    else
      redirect_to :back, flash: {error: vacation.errors.full_messages}
    end
  end
  
  private
  
  def vacation_params
    params.require(:vacation).permit(:date_requested,:start_date,:end_date,:vacation_type)
  end 
end
