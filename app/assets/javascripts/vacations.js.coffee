# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("[data-method],[data-form-action]").click (event) ->
    $('input[name=_method]').val($(this).data("method")) if $(this).data("method")
    $('#vacation_form').attr('action',$(this).data("form-action")) if $(this).data("form-action")
    $("form").submit() if $(this).hasClass("approval-btn")
    
  $("div.vacation-summary-table span").tooltip()

  #Edit button reveals editable fields
  $(".edit-btn").on "click", ->
    $(this).children().toggleClass("hidden")
    $(this).parent().siblings(".edit-field,.check-field").each () ->
      $(this).children().toggleClass("hidden")
    $(this).parent().siblings(".icon-field").each () ->
      $(this).children("a").children().toggleClass("hidden")

  #Set the end date to the start date.
  $(".start-date").on "change", ->
    $(this).parents("tr,#request-form").find(".end-date").val($(this).val())

  $(".start-date").each (index) ->
    set_business_days($(this))
  $(".date-field,input[type=checkbox]").on "change", ->
    set_business_days($(this))

  #Other...
  $("select.vacation-type").on "mouseenter mouseover mouseleave change", (event) ->
    $(this).popover('show') if $(this).siblings(".popover").length == 0
    $(this).siblings(".popover").show()
    if $(this).val() != "Other"
      $(this).siblings(".popover").hide()
  $("select.vacation-type").change ->
    return unless window.navigator.msPointerEnabled == true
    if $(this).val() != "Other"
      $(this).popover('show')
    else
      $(this).popover('hide')
  $("span.reason-show").hover ->
    $(this).popover('toggle')

set_business_days = (object) ->
  row_obj = object.parents("tr,#request-form")
  $start_date = row_obj.find(".start-date")
  $end_date = row_obj.find(".end-date")
  $half_day = row_obj.find("input.half-day")
  $business_days = row_obj.find(".business-days")
  bsn_days = calc_business_days($start_date.val(),$end_date.val(),$half_day.prop("checked"))
  $business_days.children().text(bsn_days)

thanksgivingDayUSA = (_date) ->
  year = _date.getFullYear()
  first = new Date year, 10, 1
  day_of_week = first.getDay()
  22 + (11 - day_of_week) % 7

laborDayUSA = (_date) ->
  year = _date.getFullYear()
  first = new Date year, 8, 1
  day_of_week = first.getDay()
  1 + (8 - day_of_week) % 7

memorialDayUSA = (_date) ->
  year = _date.getFullYear()
  first = new Date year, 4, 1
  day_of_week = first.getDay()
  25 + (12 - day_of_week) % 7

Date.prototype.isOrasiHoliday = ->
  (this.getMonth() == 11 and this.getDate() == 25) or #Christmas
  (this.getMonth() == 11 and this.getDate() == 24) or #Christmas eve
  (this.getMonth() == 0 and this.getDate() == 1) or #New Years Day
  (this.getMonth() == 6 and this.getDate() == 4) or #Independence Day
  (this.getMonth() == 10 and thanksgivingDayUSA(this) == this.getDate()) or #Thanksgiving
  (this.getMonth() == 10 and thanksgivingDayUSA(this)+1 == this.getDate()) or #Black Friday (day after Thanksgiving)
  (this.getMonth() == 8 and laborDayUSA(this) == this.getDate()) or #Labor Day
  (this.getMonth() == 4 and memorialDayUSA(this) == this.getDate()) #Memorial Day

Date.prototype.addDays = (days) ->
  this.setDate(this.getDate() + days * 1)

Date.prototype.isWeekend = ->
  this.getDay() == 0 or this.getDay() == 6

calc_non_business_days = (start_date, end_date) ->
  return 0 if end_date.getTime() < start_date.getTime()
  days = 0
  temp_date = new Date(start_date)
  while temp_date.getTime() != end_date.getTime()
    days += 1 if temp_date.isOrasiHoliday() or temp_date.isWeekend()
    temp_date.addDays(1)
  days += 1 if temp_date.isOrasiHoliday() or temp_date.isWeekend()
  return days

calc_business_days = (_start_date, _end_date, half_day_set) ->
  return if (typeof _start_date=="undefined") or (typeof _end_date=="undefined")
  [year,month,day]=_start_date.split("-")
  start_date = new Date(year,month-1,day)
  [year,month,day]=_end_date.split("-")
  end_date = new Date(year,month-1,day)
  return if isNaN(end_date - start_date)

  non_business_days = calc_non_business_days(start_date, end_date)
  bsn_days = Math.round((end_date - start_date)/1000/60/60/24 + 1 - (non_business_days))
  bsn_days -= 0.5 if half_day_set
  return bsn_days
