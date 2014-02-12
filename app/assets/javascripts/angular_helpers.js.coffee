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
  
AngularHelpers.initializeResource = ($scope) ->
  $scope.resourcesPerPage = 15;
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
    $scope.pagedResources = []
    return if $scope.filteredResources.length==0
    for i in [0..$scope.filteredResources.length-1]
      if i % $scope.resourcesPerPage == 0
        $scope.pagedResources[Math.floor(i / $scope.resourcesPerPage)] = [ $scope.filteredResources[i] ]
      else
        $scope.pagedResources[Math.floor(i / $scope.resourcesPerPage)].push($scope.filteredResources[i])
      $scope.initialPage = $scope.pagedResources.length-1 if String($scope.filteredResources[i].id) == previousResource()
  
