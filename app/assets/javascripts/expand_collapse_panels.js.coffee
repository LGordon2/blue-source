$ ->
  $(".expand-all-panels").on "click", ->
    $(".panel-heading[data-target]").each ->
      panel_body = $($(this).attr('data-target'))
      panel_body.collapse('show') unless panel_body.hasClass("in")
  $(".collapse-all-panels").on "click", (event) ->
    $(".panel-heading[data-target]").each ->
      panel_body = $($(this).attr('data-target'))
      panel_body.collapse('hide') unless panel_body.hasClass("collapse")
    console.log(event)
