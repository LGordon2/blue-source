class CalendarController < ApplicationController
  def index
    @all_months = (1..12).collect {|month_no| [Date.new(2014,month_no,1).strftime("%B"), month_no]}
    unless params[:year].blank? or params[:month].blank?
      @starting_date = Date.new(params[:year].to_i,params[:month].to_i,1)
    else
      @starting_date = Date.current.change(day: 1)
    end
    @pdo_times = Vacation.where.not(status: "Pending").where("start_date >= ? and start_date <= ?",@starting_date.beginning_of_month,@starting_date.end_of_month)
  end
  
end
