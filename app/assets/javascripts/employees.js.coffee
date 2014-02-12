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
    
@employees_list_app = angular.module('employees_list_app', []);

employees_list_ctrl = ($scope, $http, $filter) ->
  $http.get('employees.json').success (data) ->
    if (angular.isObject(data))
      data.forEach (value,key) ->
        value.display_name = "#{value.first_name} #{value.last_name}"
        value.manager.display_name = "#{value.manager.first_name} #{value.manager.last_name}" if value.manager?
      $scope.resources = data
    else
      $scope.resources = []
    $scope.search()
    $scope.currentPage = $scope.initialPage if $scope.initialPage
    AngularHelpers.doneLoading($scope)
  AngularHelpers.initializeResource($scope)
  
  $scope.filter_on_id = true
    
  searchMatch = AngularHelpers.searchMatch
    
  $scope.search = ->
    $scope.filteredResources = $filter('filter')($scope.resources, (employee) ->
      return searchMatch(employee.first_name, $scope.query) || searchMatch(employee.last_name, $scope.query) ||
      searchMatch(employee.display_name, $scope.query) ||
      searchMatch(employee.role, $scope.query) || 
      (employee.manager? && (searchMatch(employee.manager.first_name, $scope.query) || 
      searchMatch(employee.manager.last_name, $scope.query) || searchMatch(employee.manager.display_name, $scope.query))) || 
      (employee.project? && searchMatch(employee.project.name, $scope.query)) ||
      searchMatch(employee.location, $scope.query))
    manager_id = $scope.manager_id
    
    $scope.filteredResources = $filter('filter')($scope.filteredResources,{status:"!Inactive"}) unless $scope.show_inactive
    $scope.filteredResources = $filter('filter')($scope.filteredResources,{manager_id: parseInt($scope.current_id)},true) if $scope.current_id != ''
    $scope.filteredResources = $filter('orderBy')($scope.filteredResources,$scope.predicate,$scope.reverse)
    
    $scope.currentPage = 0;
    $scope.groupToPages()
    console.log($scope.pagedResources)
  
  
employees_list_ctrl.$inject = ['$scope', '$http', '$filter'];

@employees_list_app.controller 'employees_list_ctrl', employees_list_ctrl
  
  