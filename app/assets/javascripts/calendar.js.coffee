# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("select#month,select#year,input[type=radio]").on "change", ->
    $(this).parents("form").submit()
  $(".disabled").on "click", ->
    return false;
  $(".list-group-item").tooltip()
  $(".more-pdo").on "click", (event) ->
    $(this).siblings(".list-group-item-hidden").toggleClass("hidden")
    $(this).toggleClass("hidden")
    $(this).siblings(".more-pdo").toggleClass("hidden")
    event.preventDefault()
  $(".expand-all").on "click", ->
    if ($(".list-group-item-hidden:hidden").length > 0)
      $(".more-pdo").siblings(".list-group-item-hidden:hidden").toggleClass("hidden")
      $(".more-pdo:contains('more'):visible").toggleClass("hidden")
      $(".more-pdo:contains('Collapse'):hidden").toggleClass("hidden")
    else
      $(".more-pdo").siblings(".list-group-item-hidden:visible").toggleClass("hidden")
      $(".more-pdo:contains('more'):hidden").toggleClass("hidden") 
      $(".more-pdo:contains('Collapse'):visible").toggleClass("hidden")
  $('[data-toggle]').tooltip()

      
