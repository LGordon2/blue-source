# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(".operator-dropdown").each (index) ->
    disable_text_fields(this)
  $(".operator-dropdown").on "change", ->
    disable_text_fields(this)
  $(".glyphicon.glyphicon-remove").on "click", ->
    $(this).parents("tr").remove()
    

disable_text_fields = (row_obj) ->
  if $(row_obj).val().toLowerCase() == 'all'
    $(row_obj).parents("tr").find(".data-input-field").attr("disabled", true)
  else
    $(row_obj).parents("tr").find(".data-input-field").attr("disabled", false)
