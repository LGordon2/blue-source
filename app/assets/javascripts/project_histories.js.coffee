# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("a.edit-btn").click -> 
    row_tr = $(this).parents("tr")
    row_tr.find(".edit-field,.update-btn").show()
    row_tr.find(".data-field").hide()
    $(this).toggle()
  $("button.memo-submit").click ->
    modal_number = $(".modal.in").attr("id").split("_")[1]
    $("tr").eq(modal_number).find("input[type=hidden]").val($(".modal.in textarea[name=memo-field]").val())
  $("input[type=submit]").click ->
    $('input[name=_method]').val($(this).data("method")) if $(this).data("method")
    $('form').attr('action',$(this).data("form-action")) if $(this).data("form-action")
  $("textarea[name=memo-field]").each ->
    modal_number = $(this).parents("div.modal").attr("id").split("_")[1]
    $(this).val( $("tr").eq(modal_number).find("input[type=hidden]").val())
