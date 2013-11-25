# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@employee_list_app = angular.module('employee_list_app', []);

employee_list_ctrl = ($scope, $http) ->
  $http.get('employees.json').success (data) ->
    data.forEach (value, key) ->
      value.display_name = value.first_name[0].toUpperCase() + value.first_name[1..-1] + " " + value.last_name[0].toUpperCase() + value.last_name[1..-1]
      value.manager_name = value.manager.first_name[0].toUpperCase() + value.manager.first_name[1..-1] + " " + value.manager.last_name[0].toUpperCase() + value.manager.last_name[1..-1] if value.manager
    $scope.employees = data
  $scope.predicate = 'last_name'
  $scope.filter_on_id = true
  $scope.test = (expected, actual) ->
    return unless actual == '' then parseInt(actual) == parseInt(expected) else true

employee_list_ctrl.$inject = ['$scope', '$http'];

@employee_list_app.controller 'employee_list_ctrl', employee_list_ctrl


