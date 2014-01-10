# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require auto_set_levels
$(document).ready ->
  $(".edit-btn").on "click", ->
    $(this).children().toggleClass("hidden")
    $(this).parent().siblings(".edit-field,.check-field").each (index) ->
      $(this).children().toggleClass("hidden")
  $(".vacation-row").each (index) ->
    set_business_days($(this))
  $(".date-field,input[type=checkbox]").on "change", ->
    set_business_days($(this).parents(".vacation-row"))
  $("#employee_project_id").on "change", ->
    set_team_leads()
  $("#start_date-new").on "change", ->
    $("#end_date-new").val($(this).val())
    set_business_days($(this).parents(".vacation-row"))
  $(".vacation-type").hover ->
    if $(this).val() == "Other"
      $(this).popover('show')
      $(".popover").find("input").keyup ->
        $(this).parentsUntil("tr").last().parent().find("#vacation_reason").val($(this).val())
    else
      $(this).popover('hide') 
  $("span.reason-show").hover ->
    $(this).popover('toggle')
   

set_team_leads = ->
  employee_project_id = $("#employee_project_id")
  team_leads_select = $("select#employee_team_lead_id")
  team_lead_section = $("#team_lead_section")
  return team_lead_section.addClass("hidden") if employee_project_id.val() == ""
  $.getJSON "/project/#{employee_project_id.val()}/leads.json", (data) ->
    team_leads_select.empty()
    team_leads_select.append('<option value></option>') unless data.length == 1
    for lead in data
      name = "#{lead.first_name[0].toUpperCase() + lead.first_name[1..-1].toLowerCase()} #{lead.last_name[0].toUpperCase() + lead.last_name[1..-1].toLowerCase()}"
      team_leads_select.append("<option value=\"#{lead.id}\">"+name+'</option>')
    if data.length > 1 then team_lead_section.removeClass("hidden") else team_lead_section.addClass("hidden")
    

set_business_days = (object) ->
  id = object.attr("id").split("-")[1]
  $start_date = $("#start_date-#{id}")
  $end_date = $("#end_date-#{id}")
  bsn_days = calc_business_days($start_date.val(),$end_date.val(),object.find("input:checked").length==1)
  $("#business_days-#{id}").children().text(bsn_days)
  $("#hidden_business_days-#{id}").val(bsn_days)

@vacation_index_app = angular.module('vacation_index_app', [])

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
    days += 1 if temp_date.isWeekend()
    days += 1 if temp_date.isOrasiHoliday()
    temp_date.addDays(1)
  days += 1 if temp_date.isWeekend()
  days += 1 if temp_date.isOrasiHoliday()
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
  
  