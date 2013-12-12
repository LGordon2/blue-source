$(document).ready ->
  $(window).on "keypress", ->
    $("#search-bar").focus() unless $(".modal").attr("aria-hidden")=="false"