class VacationRequestMailer < ActionMailer::Base
  default from: "mailer@orasi.com"
  
  def request_email(current_user, to, cc=nil, vacation_params)
    if Rails.env.development?
      to = "lewis.gordon@orasi.com"
      cc = "lewis.gordon@orasi.com"
    end
    if Rails.env.staging?
      to = "bluesourceqa@gmail.com"
      cc = "bluesourceqa@gmail.com"
    end
    
    @current_user = current_user
    @vacation_params = vacation_params
    mail(to: to, cc: cc, subject: "[BlueSource] #{current_user.display_name}, #{vacation_params[:vacation_type]} Request")
  end
  
  def confirm_email(current_user, to, vacation_params, accepted)
    if Rails.env.development?
      to = "lewis.gordon@orasi.com"
    end
    if Rails.env.staging?
      to = "bluesourceqa@gmail.com"
    end

    @accepted = accepted
    @current_user = current_user
    @vacation_params = vacation_params
    @confirm_status = accepted ? "Accepted" : "Rejected"
    mail(to: to, subject: "[BlueSource] #{current_user.display_name}, #{vacation_params[:vacation_type]} #{@confirm_status.capitalize}")
  end
end
