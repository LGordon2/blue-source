# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("a.edit-btn").click -> 
    row_tr = $(this).parents("tr")
    row_tr.find(".edit-field,.update-btn").show()
    row_tr.find(".data-field").hide()
    $(this).toggle()
  $("input[type=submit]").click ->
    $('input[name=_method]').val($(this).data("method")) if $(this).data("method")
    $('form').attr('action',$(this).data("form-action")) if $(this).data("form-action")
