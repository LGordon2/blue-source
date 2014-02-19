# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
disable_text_fields = (row_obj) ->
  if $(row_obj).val().toLowerCase() == 'all'
    $(row_obj).parents("tr").find(".data-input-field:visible").attr("disabled", true)
  else
    $(row_obj).parents("tr").find(".data-input-field:visible").attr("disabled", false)
  $(row_obj).parents("tr").find(".data-input-field:hidden").each (index) ->
    $(this).attr("disabled", true)

set_data_field_type = (row_obj) ->
  if $(row_obj).val().toLowerCase() == 'projects'
     $(row_obj).parents("tr").find("select.data-input-field").removeClass("hidden")
     $(row_obj).parents("tr").find("input.data-input-field").addClass("hidden")
  else
     $(row_obj).parents("tr").find("select.data-input-field").addClass("hidden")
     $(row_obj).parents("tr").find("input.data-input-field").removeClass("hidden")
  disable_text_fields($(row_obj).parents("tr").find(".operator-dropdown"))

$ ->
  $(".operator-dropdown").each (index) ->
    disable_text_fields(this)
    $(this).on "change", ->
      disable_text_fields(this)
  $(".glyphicon.glyphicon-remove").on "click", ->
    $(this).parents("tr").remove()
  $(".column-name-dropdown").each (index) ->
    set_data_field_type(this)
    $(this).on "change", ->
      set_data_field_type(this)