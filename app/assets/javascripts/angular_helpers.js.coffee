AngularHelpers = exports? and exports or @AngularHelpers = {}

AngularHelpers.searchMatch = (haystack, needle) ->
  return false unless haystack
  return true unless needle
  return haystack.toLowerCase().indexOf(needle.toLowerCase()) != -1