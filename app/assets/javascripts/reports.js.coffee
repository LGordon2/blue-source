# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
disable_text_fields = (row_obj) ->
  if $(row_obj).val().toLowerCase() in ['all','nil']
    $(row_obj).parents("tr").find(".report-input-fields").children(":visible").each (index)->
      $(this).attr("disabled",true)
  else
    $(row_obj).parents("tr").find(".report-input-fields").children(":visible").each (index)->
      $(this).attr("disabled",false)
  $(row_obj).parents("tr").find(".report-input-fields").children(":hidden").each (index)->
      $(this).attr("disabled",true)

set_data_field_type = (row_obj) ->
  report_input_fields = $(row_obj).parents("tr").find(".report-input-fields")
  report_input_fields.children().each (index) ->
    $(this).addClass("hidden")
    
  if $(row_obj).val().toLowerCase() in ['projects','departments']
    console.log($(row_obj).val().toLowerCase())
    report_input_fields.find(".#{$(row_obj).val().toLowerCase()}").removeClass("hidden")
  else
    report_input_fields.find(".text").removeClass("hidden")
      
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