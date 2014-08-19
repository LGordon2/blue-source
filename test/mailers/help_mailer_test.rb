require 'test_helper'

class HelpMailerTest < ActionMailer::TestCase
  test "mailer works" do
    from = "Test User"
    email = "test.user@orasi.com"
    comments = "I hate blue source"
    type = "Bug"
    email = HelpMailer.comments_email(from, email, comments, type).deliver
    assert !ActionMailer::Base.deliveries.empty?
  end
  
  test "login mailer works" do
    from = "Test User"
	email = "test.user@orasi.com"
    comments = "I actually love blue source"
    email = HelpMailer.login_help_email(from, email, comments).deliver
    assert !ActionMailer::Base.deliveries.empty?
  end
end
