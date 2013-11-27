# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@project_list_app = angular.module('project_list_app', []);

project_list_ctrl = ($scope, $http) ->
  $http.get('projects.json').success (data) ->
    data.forEach (value, key) ->
      value.lead.display_name = value.lead.first_name[0].toUpperCase() + value.lead.first_name[1..-1] + " " + value.lead.last_name[0].toUpperCase() + value.lead.last_name[1..-1] if value.lead
    $scope.projects = data
  $scope.predicate = 'name'

project_list_ctrl.$inject = ['$scope', '$http'];

@project_list_app.controller 'project_list_ctrl', project_list_ctrl