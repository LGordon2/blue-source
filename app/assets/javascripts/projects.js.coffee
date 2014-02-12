# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require auto_focus_search
#= require angular_helpers

@projects_list_app = angular.module('projects_list_app', []);

projects_list_ctrl = ($scope, $http, $filter) ->
  $http.get('projects.json').success (data) ->
    data.forEach (value, key) ->
      all_leads = ("#{lead.first_name[0].toUpperCase() + lead.first_name[1..-1].toLowerCase()} #{lead.last_name[0].toUpperCase() + lead.last_name[1..-1].toLowerCase()}" for lead in value.leads)
      value.all_leads = all_leads.sort().join(", ")
      value.client_partner.display_name = value.client_partner.first_name[0].toUpperCase()+value.client_partner.first_name[1..-1].toLowerCase() + " " + value.client_partner.last_name[0].toUpperCase()+value.client_partner.last_name[1..-1].toLowerCase() if value.client_partner
    $scope.resources = data
    $scope.search()
    $scope.loaded=true
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