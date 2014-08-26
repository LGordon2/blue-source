require 'test_helper'

class VacationsControllerTest < ActionController::TestCase
  def setup
    @manager = employees(:manager)
    assert @manager.save
    @manager2 = employees(:manager2)
    assert @manager2.save
    @consultant = employees(:consultant)
    assert @consultant.save
    @consultant2 = employees(:consultant2)
    assert @consultant2.save
    @director = employees(:upper_manager)
    assert @director.save
    @admin = employees(:department_admin)
    assert @admin.save
    @vacation = vacations(:one)
    @vacation.manager = @manager
    @vacation.employee = @consultant
    assert @vacation.save

    @pending_vacation = vacations(:pending)
    assert @pending_vacation.save, @pending_vacation.errors.full_messages

    request.env['HTTP_REFERER'] = root_url
    @sick_day_params = { vacation: { date_requested: '2013-12-17', business_days: 1, start_date: '2013-12-17', end_date: '2013-12-17', vacation_type: 'Sick' } }
  end

  test 'should not get index if user not logged in' do
    get :index, employee_id: @consultant.id
    assert_redirected_to :login
  end

  test "should not get error from new if user's manager" do
    get :index, { employee_id: @consultant.id }, current_user_id: @manager.id
    assert_response :success
  end

  test "should get error from new if not user's manager" do
    get :index, { employee_id: @consultant2.id }, current_user_id: @manager.id
    assert_redirected_to :root
    assert_not_nil flash[:error]
  end

  test "should not get error from new if user's manager's manager" do
    get :index, { employee_id: @consultant.id }, current_user_id: @director.id
    assert_response :success
    assert_nil flash[:error]
  end

  test "should get error from new if not user's manager's manager" do
    get :index, { employee_id: @consultant2.id }, current_user_id: @director.id
    assert_redirected_to :root
    assert_not_nil flash[:error]
  end

  test 'should not get error from new if admin' do
    get :index, { employee_id: @consultant.id }, current_user_id: @admin.id
    assert_not_nil @admin.department
    assert_nil flash[:error]
  end

  test "consultants can't change each other's vacation" do
    get :index, { employee_id: @consultant2.id }, current_user_id: @consultant.id
    assert_redirected_to view_employee_vacations_path(@consultant.id)
  end

  test "consultant's manager should be able to delete consultant's vacation" do
    delete :destroy, { employee_id: @consultant.id, id: @vacation.id }, current_user_id: @manager.id
    assert_redirected_to :root
    assert_nil flash[:error]
  end

  test "consultant's manager's manager should be able to delete consultant's vacation" do
    delete :destroy, { employee_id: @consultant.id, id: @vacation.id }, current_user_id: @director.id
    assert_redirected_to :root
    assert_nil flash[:error]
  end

  test "not consultant's manager should not be able to delete consultant's vacation" do
    delete :destroy, { employee_id: @consultant.id, id: @vacation.id }, current_user_id: @manager2.id
    assert_redirected_to :root
    assert_not_nil flash[:error]
  end

  test "admin should be able to delete consultant's vacation" do
    delete :destroy, { employee_id: @consultant.id, id: @vacation.id }, current_user_id: @admin.id
    assert_redirected_to :root
    assert_nil flash[:error]
  end

  test 'manager should be redirected to root when trying to manage own vacation' do
    get :index, { employee_id: @manager.id }, current_user_id: @manager
    assert_redirected_to :root
  end

  test 'flash is not nil when navigating to view vacations' do
    get :view, employee_id: @consultant.id
    assert_not_nil flash[:error]
  end

  test 'manager should be able to create a vacation for employee' do
    date = Date.new(2014, 07, 01)
    type = Vacation.types.sample
    reason = 'This is a test' if type == 'Other'
    params = {
      vacation: {
        date_requested: date,
        start_date: date,
        end_date: date,
        vacation_type: type,
        reason: reason
      },
      employee_id: @consultant.id
    }

    post :create, params, current_user_id: @manager
    assert_nil flash[:error]
  end

  test 'mail is generated on vacation request' do
    vacation_type = 'Sick'
    ActionMailer::Base.deliveries.clear
    post :requests, { employee_id: @consultant.id, vacation: { date_requested: Time.now, start_date: Time.now, end_date: Time.now, vacation_type: vacation_type } }, current_user_id: @consultant.id
    assert_nil flash[:error]
    assert_equal 1, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries.first
    assert_includes mail.subject, "#{vacation_type} Request"
  end

  test 'other pdo request cannot be made' do
    vacation_type = 'Other'
    prev_vacation_count = Vacation.count
    ActionMailer::Base.deliveries.clear
    post :requests, { employee_id: @consultant.id, vacation: { date_requested: Time.now, start_date: Time.now, end_date: Time.now, vacation_type: vacation_type } }, current_user_id: @consultant.id
    assert_not_nil flash[:error]
    assert_equal prev_vacation_count, Vacation.count
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test 'mail is generated on vacation accept' do
    prev_vacation_count = Vacation.count
    assert @pending_vacation.pending?
    ActionMailer::Base.deliveries.clear
    put :update, { employee_id: @consultant.id, id: @pending_vacation.id, "#{@pending_vacation.id}" => { vacation: { status: '' } }, confirm: 'true' }, current_user_id: @manager.id
    assert_nil flash[:error]
    assert_equal prev_vacation_count, Vacation.count
    assert_equal 1, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries.first
    assert_includes mail.subject, "#{@pending_vacation.vacation_type} Accepted"
  end

  test 'mail is generated on vacation rejected' do
    prev_vacation_count = Vacation.count
    assert @pending_vacation.pending?
    ActionMailer::Base.deliveries.clear
    put :update, { employee_id: @consultant.id, id: @pending_vacation.id, "#{@pending_vacation.id}" => { vacation: { status: '' } }, confirm: 'false' }, current_user_id: @manager.id
    assert_nil flash[:error]
    assert_equal prev_vacation_count, Vacation.count
    assert_equal 1, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries.first
    assert_includes mail.subject, "#{@pending_vacation.vacation_type} Rejected"
  end

  test 'mail is generated on vacation cancellation' do
    prev_vacation_count = Vacation.count
    ActionMailer::Base.deliveries.clear
    delete :cancel, { employee_id: @consultant.id, id: @pending_vacation.id }, current_user_id: @consultant.id
    assert_nil flash[:error]
    assert_equal prev_vacation_count - 1, Vacation.count
    assert_equal 1, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries.first
    assert_includes mail.subject, "Cancel #{@pending_vacation.vacation_type} Request"
  end

  test 'no mail is generated on non pending vacation deletion' do
    prev_vacation_count = Vacation.count
    ActionMailer::Base.deliveries.clear
    delete :destroy, { employee_id: @consultant.id, id: @vacation.id }, current_user_id: @manager.id
    assert_nil flash[:error]
    assert_equal prev_vacation_count - 1, Vacation.count
    assert_equal 0, ActionMailer::Base.deliveries.size
  end
end
