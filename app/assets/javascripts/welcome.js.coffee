# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@employee_list_app = angular.module('employee_list_app', []);

employee_list_ctrl = ($scope, $http, $filter) ->
  $http.get('employees.json').success (data) ->
    data.forEach (value, key) ->
      value.display_name = value.first_name[0].toUpperCase() + value.first_name[1..-1] + " " + value.last_name[0].toUpperCase() + value.last_name[1..-1]
      value.manager_name = value.manager.first_name[0].toUpperCase() + value.manager.first_name[1..-1] + " " + value.manager.last_name[0].toUpperCase() + value.manager.last_name[1..-1] if value.manager
    $scope.employees = data
    $scope.search()
  $scope.predicate = 'last_name'
  $scope.sortingOrder = 'name';
  employeesPerPage = 10;
  
  $scope.filter_on_id = true
  $scope.test = (expected, actual) ->
    return unless actual == '' then parseInt(actual) == parseInt(expected) else true

  searchMatch = (haystack, needle) ->
    return true unless needle
    return haystack.toLowerCase().indexOf(needle.toLowerCase()) != -1
    
  $scope.search = ->
    $scope.filteredEmployees = $filter('filter')($scope.employees, (employee) ->
      return searchMatch(employee.display_name, $scope.query) || searchMatch(employee.role, $scope.query) || 
      (searchMatch(employee.manager.first_name, $scope.query) || searchMatch(employee.manager.last_name, $scope.query) && employee.manager?) || (searchMatch(employee.project.name, $scope.query) if employee.project?)
    )
    
    $scope.filteredEmployees = $filter('orderBy')($scope.filteredEmployees,$scope.predicate,$scope.reverse)
    
    $scope.currentPage = 0;
    $scope.groupToPages()
    
  $scope.groupToPages = () ->
    $scope.pagedEmployees = []
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


