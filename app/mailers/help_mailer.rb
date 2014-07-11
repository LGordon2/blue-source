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
  end

  private

  def default_emails
    ["lewis.gordon@orasi.com","perry.thomas@orasi.com",
      "adam.thomas@orasi.com","david.quach@orasi.com", "ethan.bell@orasi.com"]
  end
end
