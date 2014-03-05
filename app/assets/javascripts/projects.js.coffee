# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require auto_focus_search
#= require angular_helpers

@projects_list_app = angular.module('projects_list_app', []);

projects_list_ctrl = ($scope, $http, $filter) ->
  AngularHelpers.getResources($scope,$http,'projects.json')
  AngularHelpers.initializeResource($scope)
  $scope.predicate = 'name'
  
  $scope.filter_on_id = true

  searchMatch = AngularHelpers.searchMatch
    
  $scope.search = ->
    $scope.filteredResources = $filter('filter')($scope.resources, (project) ->
      return searchMatch(project.name, $scope.query) || searchMatch(project.all_leads, $scope.query) || searchMatch(project.status, $scope.query) 
    )
    $scope.filteredResources = $filter('filter')($scope.filteredResources,{status:"!Inactive"}) unless $scope.show_inactive
    $scope.filteredResources = $filter('orderBy')($scope.filteredResources,$scope.predicate,$scope.reverse)
    
    $scope.currentPage = 0;
    $scope.groupToPages()

projects_list_ctrl.$inject = ['$scope', '$http', '$filter'];

@projects_list_app.controller 'projects_list_ctrl', projects_list_ctrl