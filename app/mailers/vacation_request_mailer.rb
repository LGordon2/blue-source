class VacationRequestMailer < ActionMailer::Base
  default from: "bluesource@orasi.com"
  
  before_action :attach_logo
  
  def request_email(from_user, to_manager, vacation, memo, cc=nil)
    if Rails.env.development?
      to_manager.email = "lewis.gordon@orasi.com"
      cc = "lewis.gordon@orasi.com"
    end
    @memo = memo
    @from_user = from_user
    @to_manager = to_manager
    @vacation = vacation

    mail(to: @to_manager.email, cc: cc, subject: "[BlueSource] #{from_user.display_name}, #{request_type(from_user, vacation)} Request")
  end
  
  def confirm_email(from_manager, to_employee, vacation, accepted)
    if Rails.env.development?
      to_employee.email = "lewis.gordon@orasi.com"
    end
    @to_employee = to_employee
    @from_manager = from_manager
    @vacation = vacation
    @accepted = accepted
    @confirm_status = accepted ? "Accepted" : "Rejected"
    mail(to: @to_employee.email, subject: "[BlueSource] #{@from_manager.display_name}, #{request_type(to_employee, vacation)} #{@confirm_status.capitalize}")
  end
  
  private
  
  def attach_logo
    attachments.inline['logo.png'] = File.read(Rails.root.to_path+"/app/assets/images/logo.png")
  end
  
  def request_type(employee, vacation)
    unless vacation.reason.blank? or employee.status != "Contractor" 
      vacation.reason
    else 
      vacation.vacation_type
    end
  end
end
