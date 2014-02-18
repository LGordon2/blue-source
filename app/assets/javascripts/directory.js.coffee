# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require auto_focus_search
#= require angular_helpers

@directory_list_app = angular.module('directory_list_app', []);

directory_list_ctrl = ($scope, $http, $filter) ->
  $scope.getAllEmployees = (fromDepartment) ->
    AngularHelpers.loading($scope)
    url = if typeof(fromDepartment) == 'undefined' then '/directory/employees.json' else "/departments/#{fromDepartment}/employees.json"
    AngularHelpers.getResources($scope, $http,url)
  AngularHelpers.initializeResource($scope)
  $scope.getAllEmployees()

  searchMatch = AngularHelpers.searchMatch
    
  $scope.search = ->
    $scope.filteredResources = $filter('filter')($scope.resources,{status: "!Inactive"})
    $scope.filteredResources = $filter('filter')($scope.filteredResources, (employee) ->
      
      return searchMatch(employee.first_name, $scope.query) || searchMatch(employee.last_name, $scope.query) ||
      searchMatch(employee.display_name, $scope.query) ||
      (employee.manager? && (searchMatch(employee.manager.first_name, $scope.query) || 
      searchMatch(employee.manager.last_name, $scope.query) || searchMatch(employee.manager.display_name, $scope.query))) || 
      (employee.department? && searchMatch(employee.department.name, $scope.query)) ||
      searchMatch(employee.office_phone, $scope.query) ||
      searchMatch(employee.cell_phone, $scope.query) ||
      (employee.im_name? && searchMatch(employee.im_name, $scope.query)) ||
      (employee.im_client && searchMatch(employee.im_client, $scope.query))
      )
    manager_id = $scope.manager_id
    $scope.filteredResources = $filter('orderBy')($scope.filteredResources,$scope.predicate,$scope.reverse)

    $scope.currentPage = 0;
    $scope.groupToPages()
    
directory_list_ctrl.$inject = ['$scope', '$http', '$filter'];

@directory_list_app.controller 'directory_list_ctrl', directory_list_ctrl