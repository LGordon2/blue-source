# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require auto_focus_search

@project_list_app = angular.module('project_list_app', []);

project_list_ctrl = ($scope, $http, $filter) ->
  $http.get('projects.json').success (data) ->
    data.forEach (value, key) ->
      #value.lead.display_name = value.lead.first_name[0].toUpperCase() + value.lead.first_name[1..-1] + " " + value.lead.last_name[0].toUpperCase() + value.lead.last_name[1..-1] if value.lead
      all_leads = ("#{lead.first_name[0].toUpperCase() + lead.first_name[1..-1].toLowerCase()} #{lead.last_name[0].toUpperCase() + lead.last_name[1..-1].toLowerCase()}" for lead in value.leads)
      value.all_leads = all_leads.join(", ")
    $scope.projects = data
    $scope.search()
  $scope.predicate = 'name'
  $scope.reverse = false
  $scope.current_id = ''
  $scope.sortingOrder = 'name';
  projectsPerPage = 10;
  
  $scope.filter_on_id = true

  searchMatch = (haystack, needle) ->
    return false unless haystack
    return true unless needle
    return haystack.toLowerCase().indexOf(needle.toLowerCase()) != -1
    
  $scope.search = ->
    $scope.filteredProjects = $filter('filter')($scope.projects, (project) ->
      return searchMatch(project.name, $scope.query) || searchMatch(project.all_leads, $scope.query) || searchMatch(project.status, $scope.query) 
    )
    
    $scope.filteredProjects = $filter('orderBy')($scope.filteredProjects,$scope.predicate,$scope.reverse)
    
    $scope.currentPage = 0;
    $scope.groupToPages()
    
  $scope.groupToPages = () ->
    $scope.pagedProjects = []
    return if $scope.filteredProjects.length==0
    for i in [0..$scope.filteredProjects.length-1]
      if i % projectsPerPage == 0
        $scope.pagedProjects[Math.floor(i / projectsPerPage)] = [ $scope.filteredProjects[i] ]
      else
        $scope.pagedProjects[Math.floor(i / projectsPerPage)].push($scope.filteredProjects[i])

  $scope.range = (start,end) ->
    [start..end-1]
  
  $scope.setPage = ->
    $scope.currentPage = this.n;
    
  $scope.nextPage = ->
    $scope.currentPage++ if ($scope.currentPage < $scope.pagedProjects.length - 1)
    
  $scope.prevPage = ->
    $scope.currentPage-- if ($scope.currentPage > 0)

project_list_ctrl.$inject = ['$scope', '$http', '$filter'];

@project_list_app.controller 'project_list_ctrl', project_list_ctrl