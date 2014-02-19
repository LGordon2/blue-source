$("tr:last").after($("<%= escape_javascript(render partial: 'form_section', locals: {selected_column: nil, selected_operator: nil, text: nil})%>"))

$(".operator-dropdown").on "change", ->
  disable_text_fields(this)
  
$(".glyphicon.glyphicon").on "click", ->
  $(this).parents("tr").remove()
    
disable_text_fields = (row_obj) ->
  if $(row_obj).val().toLowerCase() == 'all'
    $(row_obj).parents("tr").find(".data-input-field").attr("disabled", true)
  else
    $(row_obj).parents("tr").find(".data-input-field").attr("disabled", false)
