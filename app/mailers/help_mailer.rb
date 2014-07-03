class HelpMailer < ActionMailer::Base
  default from: "bluesource@orasi.com"
  
  def comments_email(from, email, comments, type)
    @from = from
    @comments = comments
    @email = email
    @type = type
    mail(bcc: default_emails, subject: "#{type} submitted by #{from}")
  end
  
  def login_help_email(from, email, comments)
    @from = from
    @email = email
    @comments = comments
    @type = 'Login issue'
	mail(bcc: default_emails, subject: "Login issue submitted by #{from}")
    #mail(to: 'ethan.bell@orasi.com', bcc: default_emails, subject: "Login issue submitted by #{from}")
  end
  
  private
  
  def default_emails
    return "lewis.gordon@orasi.com" if Rails.env.development?
    ["lewis.gordon@orasi.com","perry.thomas@orasi.com",
      "adam.thomas@orasi.com","john.martin@orasi.com",
      "lateef.livers@orasi.com","kevin.hedgecock@orasi.com",
      "jason.trogdon@orasi.com"]
  end
end
