AngularHelpers = exports? and exports or @AngularHelpers = {}

previousResource = ->
    match = /\/employees\/(\d+)/.exec(document.referrer)
    if match
      match[1]

AngularHelpers.searchMatch = (haystack, needle) ->
  return false unless haystack
  return true unless needle
  return haystack.toLowerCase().indexOf(needle.toLowerCase()) != -1

AngularHelpers.doneLoading = ($scope) ->
  $scope.loaded = true

AngularHelpers.loading = ($scope) ->
  $scope.loaded = false

AngularHelpers.getResources = ($scope, $http,json_file) ->
  AngularHelpers.loading($scope)
  $http.get(json_file).success((data) ->
    if (angular.isObject(data))
      $scope.resources = data
    else
      $scope.resources = []
    $scope.search()
    $scope.currentPage = $scope.initialPage if $scope.initialPage and $scope.goToInitialPage
    AngularHelpers.doneLoading($scope))


AngularHelpers.initializeResource = ($scope) ->
  $scope.goToInitialPage = true
  $scope.resourcesPerPage = 15;
  $scope.numberOfPages = 10;
  $scope.loaded=false
  $scope.loadProgress=100
  $scope.show_inactive=false
  $scope.predicate = 'first_name'
  $scope.directReports = false
  $scope.reverse = false
  $scope.current_id = ''
  $scope.sortingOrder = 'name';

  $scope.range = (start,end) ->
    [start..end-1]

  $scope.setPage = ->
    $scope.currentPage = this.n;

  $scope.nextPage = ->
    $scope.currentPage++ if ($scope.currentPage < $scope.pagedResources.length - 1)

  $scope.prevPage = ->
    $scope.currentPage-- if ($scope.currentPage > 0)

  $scope.groupToPages = () ->
    $scope.resourcesPerPage = 15 if $scope.resourcesPerPage <= 0
    $scope.pagedResources = []
    return if $scope.filteredResources.length==0
    for i in [0..$scope.filteredResources.length-1]
      if i % $scope.resourcesPerPage == 0
        $scope.pagedResources[Math.floor(i / $scope.resourcesPerPage)] = [ $scope.filteredResources[i] ]
      else
        $scope.pagedResources[Math.floor(i / $scope.resourcesPerPage)].push($scope.filteredResources[i])
      $scope.initialPage = $scope.pagedResources.length-1 if String($scope.filteredResources[i].id) == previousResource()

  $scope.getPageNumbers = () ->
    return if typeof($scope.pagedResources) == "undefined" or typeof($scope.currentPage) == "undefined"
    if $scope.pagedResources.length > $scope.numberOfPages
      if $scope.pagedResources.length - $scope.currentPage > $scope.numberOfPages
        [$scope.currentPage...$scope.currentPage+$scope.numberOfPages]
      else
        [$scope.pagedResources.length-$scope.numberOfPages...$scope.pagedResources.length]
    else
      [0...$scope.pagedResources.length]
