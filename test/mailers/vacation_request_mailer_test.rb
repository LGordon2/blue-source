require 'test_helper'

class VacationRequestMailerTest < ActionMailer::TestCase
  test 'contractor vacation set as reason for contractor vacation' do
    from_user = employees(:contractor)
    to_manager = employees(:manager)
    vacation = vacations(:contractor_vacation)
    memo = 'Testing'
    VacationRequestMailer.request_email(from_user, to_manager, vacation, memo).deliver
    assert !ActionMailer::Base.deliveries.empty?
  end
end
