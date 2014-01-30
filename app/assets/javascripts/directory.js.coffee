# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require auto_focus_search

@employee_list_app = angular.module('employee_list_app', []);

employee_list_ctrl = ($scope, $http, $filter) ->
  $http.get('/directory/employees.json').success (data) ->
    if (angular.isObject(data))
      data.forEach (value,key) ->
        value.display_name = "#{value.first_name} #{value.last_name}"
        value.manager.display_name = "#{value.manager.first_name} #{value.manager.last_name}" if value.manager?
      $scope.employees = data
    else
      $scope.employees = []
    $scope.search()
    $scope.loaded=true
  $scope.loaded=false
  $scope.predicate = 'last_name'
  $scope.reverse = false
  $scope.current_id = ''
  $scope.sortingOrder = 'name'
  employeesPerPage = 10
  $scope.resourcesPerPage = employeesPerPage
  
  $scope.filter_on_id = true
  $scope.test = (expected, actual) ->
    return unless actual == '' then parseInt(actual) == parseInt(expected) else true
    
  $scope.here = (obj) ->
    console.log(obj)

  searchMatch = (haystack, needle) ->
    return false unless haystack
    return true unless needle
    return haystack.toLowerCase().indexOf(needle.toLowerCase()) != -1
    
  $scope.search = ->
    $scope.filteredEmployees = $filter('filter')($scope.employees,{status: "!Inactive"})
    $scope.filteredEmployees = $filter('filter')($scope.filteredEmployees,{department: $scope.filteredDepartment}) unless $scope.filteredDepartment == ''
    $scope.filteredEmployees = $filter('filter')($scope.filteredEmployees, (employee) ->
      return searchMatch(employee.first_name, $scope.query) || searchMatch(employee.last_name, $scope.query) ||
      searchMatch(employee.display_name, $scope.query) ||
      (employee.manager? && (searchMatch(employee.manager.first_name, $scope.query) || 
      searchMatch(employee.manager.last_name, $scope.query) || searchMatch(employee.manager.display_name, $scope.query))) || 
      searchMatch(employee.department, $scope.query) ||
      searchMatch(employee.office_phone, $scope.query) ||
      searchMatch(employee.cell_phone, $scope.query)
      )
    manager_id = $scope.manager_id
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