$ ->
  $(".expand-all-panels").on "click", ->
    $(".panel-heading[data-target]").each (index) ->
      panel_body = $($(this).attr('data-target'))
      panel_body.collapse('show') unless panel_body.hasClass("in")
  $(".collapse-all-panels").on "click", ->
    $(".panel-heading[data-target]").each (index) ->
      panel_body = $($(this).attr('data-target'))
      panel_body.collapse('hide') if panel_body.hasClass("in")
