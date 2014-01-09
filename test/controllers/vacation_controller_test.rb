require 'test_helper'

class VacationControllerTest < ActionController::TestCase
  def setup
    @manager = employees(:manager)
    @manager2 = employees(:manager2)
    @consultant = employees(:consultant)
    @consultant2 = employees(:consultant2)
    @director = employees(:director)
    @admin = employees(:admin)
    @vacation = vacations(:one)
    @vacation.manager = @manager
    @vacation.employee = @consultant
    @vacation.save
    
    request.env["HTTP_REFERER"] = root_url()
    @sick_day_params = {vacation: {date_requested: "2013-12-17", business_days: 1, start_date: "2013-12-17", end_date: "2013-12-17", vacation_type: "Sick"}}
  end
  
  test "should not get new if user not logged in" do
    get :new
    assert_redirected_to :login
  end

  test "should not get error from new if user's manager" do
    @sick_day_params[:vacation][:employee_id] = @consultant.id
    get :new, @sick_day_params, {current_user_id: @manager.id}
    assert_nil flash[:error]
  end
  
  test "should get error from new if not user's manager" do
    @sick_day_params[:vacation][:employee_id] = @consultant2.id
    get :new, @sick_day_params, {current_user_id: @manager.id}
    assert_not_nil flash[:error]
  end
  
  test "should not get error from new if user's manager's manager" do
    @sick_day_params[:vacation][:employee_id] = @consultant.id
    get :new, @sick_day_params, {current_user_id: @director.id}
    assert_nil flash[:error]
  end
  
  test "should get error from new if not user's manager's manager" do
    @sick_day_params[:vacation][:employee_id] = @consultant2.id
    get :new, @sick_day_params, {current_user_id: @director.id}
    assert_not_nil flash[:error]
  end
  
  test "should not get error from new if admin" do
    @sick_day_params[:vacation][:employee_id] = @consultant.id
    get :new, @sick_day_params, {current_user_id: @admin.id}
    assert_nil flash[:error]
  end

  test "consultants can't change each other's vacation" do
    @sick_day_params[:vacation][:employee_id] = @consultant.id
    get :new, @sick_day_params, {current_user_id: @consultant.id}
    assert_redirected_to consultant_vacation_path(@consultant)
  end

  test "consultant's manager should be able to delete consultant's vacation" do
    delete :destroy, {id: @vacation.id}, {current_user_id: @manager.id} 
    assert_nil flash[:error]
  end
  
  test "consultant's manager's manager should be able to delete consultant's vacation" do
    delete :destroy, {id: @vacation.id}, {current_user_id: @director.id} 
    assert_nil flash[:error]
  end
    
  test "not consultant's manager should not be able to delete consultant's vacation" do
    delete :destroy, {id: @vacation.id}, {current_user_id: @manager2.id} 
    assert_not_nil flash[:error]
  end
  
  test "admin should be able to delete consultant's vacation" do
    delete :destroy, {id: @vacation.id}, {current_user_id: @admin.id} 
    assert_nil flash[:error]
  end

end
