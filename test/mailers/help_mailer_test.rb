require 'test_helper'

class HelpMailerTest < ActionMailer::TestCase
  test "mailer works" do
    from = "Test User"
    email = "test.user@orasi.com"
    comments = "I hate blue source"
    type = "Bug"
    email = HelpMailer.comments_email(from, email, comments, type).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal ['lewis.gordon@orasi.com'], email.to
  end
end
