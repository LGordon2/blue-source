# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@phonecatApp = angular.module('employee_list_app', []);

@phonecatApp.controller 'employee_list_ctrl', ($scope, $http) ->
  $http.get('employees.json').success (data) ->
    data.forEach (value, key) ->
      value.display_name = value.first_name[0].toUpperCase() + value.first_name[1..-1] + " " + value.last_name[0].toUpperCase() + value.last_name[1..-1]
      value.manager_name = value.manager.first_name[0].toUpperCase() + value.manager.first_name[1..-1] + " " + value.manager.last_name[0].toUpperCase() + value.manager.last_name[1..-1]
    $scope.employees = data
  $scope.predicate = 'last_name';