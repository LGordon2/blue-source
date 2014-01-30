class VacationRequestMailer < ActionMailer::Base
  default from: "mailer@orasi.com"
  
  before_action :attach_logo
  
  def request_email(from_user, to_manager, vacation_params, memo, cc=nil)
    if Rails.env.development?
      to_manager.email = "lewis.gordon@orasi.com"
      cc = "lewis.gordon@orasi.com"
    end
    if Rails.env.staging?
      to_manager.email = "bluesourceqa@gmail.com"
      cc = "bluesourceqa@gmail.com"
    end
    @memo = memo
    @from_user = from_user
    @to_manager = to_manager
    @vacation_params = vacation_params
    
    mail(to: @to_manager.email, cc: cc, subject: "[BlueSource] #{from_user.display_name}, #{vacation_params[:vacation_type]} Request")
  end
  
  def confirm_email(from_manager, to_employee, vacation, accepted)
    if Rails.env.development?
      to_employee.email = "lewis.gordon@orasi.com"
    end
    if Rails.env.staging?
      to_employee.email = "bluesourceqa@gmail.com"
    end
    @to_employee = to_employee
    @from_manager = from_manager
    @vacation = vacation
    @accepted = accepted
    @confirm_status = accepted ? "Accepted" : "Rejected"
    mail(to: @to_employee.email, subject: "[BlueSource] #{@from_manager.display_name}, #{@vacation.vacation_type} #{@confirm_status.capitalize}")
  end
  
  private
  
  def attach_logo
    attachments.inline['logo.png'] = File.read(Rails.root.to_path+"/app/assets/images/logo.png")
  end
end
