# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require auto_focus_search
#= require auto_add_departments
#= require auto_set_levels
#= require angular_helpers

window.setEvent = ->
  $(".popover input").each (index) ->
    $(this).parentsUntil("tr").last().parent().find("#vacation_reason").val($(this).val())

$(document).ready ->
  $("#employee_project_id").on "change", ->
    set_team_leads()
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
    
@employee_list_app = angular.module('employee_list_app', []);

employee_list_ctrl = ($scope, $http, $filter) ->
  $http.get('employees.json').success (data) ->
    if (angular.isObject(data))
      data.forEach (value,key) ->
        value.display_name = "#{value.first_name} #{value.last_name}"
        value.manager.display_name = "#{value.manager.first_name} #{value.manager.last_name}" if value.manager?
      $scope.employees = data
    else
      $scope.employees = []
    $scope.search()
    $scope.loaded=true
  $scope.current_id = 57
  $scope.loaded=false
  $scope.loadProgress=100
  $scope.show_inactive=false
  $scope.predicate = 'last_name'
  $scope.directReports = false
  $scope.reverse = false
  $scope.current_id = ''
  $scope.sortingOrder = 'name';
  employeesPerPage = 15;
  $scope.resourcesPerPage = employeesPerPage;
  
  $scope.filter_on_id = true
    
  searchMatch = AngularHelpers.searchMatch
    
  $scope.search = ->
    $scope.filteredEmployees = $filter('filter')($scope.employees, (employee) ->
      return searchMatch(employee.first_name, $scope.query) || searchMatch(employee.last_name, $scope.query) ||
      searchMatch(employee.display_name, $scope.query) ||
      searchMatch(employee.role, $scope.query) || 
      (employee.manager? && (searchMatch(employee.manager.first_name, $scope.query) || 
      searchMatch(employee.manager.last_name, $scope.query) || searchMatch(employee.manager.display_name, $scope.query))) || 
      (employee.project? && searchMatch(employee.project.name, $scope.query)) ||
      searchMatch(employee.location, $scope.query))
    manager_id = $scope.manager_id

    $scope.filteredEmployees = $filter('filter')($scope.filteredEmployees,{status:"!Inactive"}) unless $scope.show_inactive
    $scope.filteredEmployees = $filter('filter')($scope.filteredEmployees,{manager_id: parseInt($scope.current_id)},true) if $scope.current_id != ''
    $scope.filteredEmployees = $filter('orderBy')($scope.filteredEmployees,$scope.predicate,$scope.reverse)
    
    $scope.currentPage = 0;
    $scope.groupToPages()
    
  $scope.groupToPages = () ->
    $scope.pagedEmployees = []
    return if $scope.filteredEmployees.length==0
    for i in [0..$scope.filteredEmployees.length-1]
      if i % employeesPerPage == 0
        $scope.pagedEmployees[Math.floor(i / employeesPerPage)] = [ $scope.filteredEmployees[i] ]
      else
        $scope.pagedEmployees[Math.floor(i / employeesPerPage)].push($scope.filteredEmployees[i])

  $scope.range = (start,end) ->
    [start..end-1]
  
  $scope.setPage = ->
    $scope.currentPage = this.n;
    
  $scope.nextPage = ->
    $scope.currentPage++ if ($scope.currentPage < $scope.pagedEmployees.length - 1)
    
  $scope.prevPage = ->
    $scope.currentPage-- if ($scope.currentPage > 0)
  
  
employee_list_ctrl.$inject = ['$scope', '$http', '$filter'];

@employee_list_app.controller 'employee_list_ctrl', employee_list_ctrl
  
  