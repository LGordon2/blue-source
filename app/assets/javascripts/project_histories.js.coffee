# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("a.edit-btn").click ->
    row_tr = $(this).parents("tr")
    row_tr.find(".edit-field,.update-btn").show()
    row_tr.find(".data-field").hide()
    row_tr.find(".memo-link").removeAttr("disabled")
    $(this).toggle()
  $("button.memo-submit").click ->
    $(this).text($(this).data("disable-with")).attr("disabled", true)
    modal_number = $(".modal.in").attr("id").split("_")[1]
    $("tr").eq(modal_number).find("input[type=hidden]").val($(".modal.in textarea[name=memo-field]").val())
  $("input[type=submit]").click ->
    $('input[name=_method]').val($(this).data("method")) if $(this).data("method")
    $('form').attr('action',$(this).data("form-action")) if $(this).data("form-action")
  $("textarea[name=memo-field]").each ->
    modal_number = $(this).parents("div.modal").attr("id").split("_")[1]
    $(this).val( $("tr").eq(modal_number).find("input[type=hidden]").val())
  $("textarea[name=memo-field]").on "keyup", ->
    $(this).parent().siblings().find("button.memo-submit").text("Save").removeAttr("disabled")
  $(".project-dropdown").on "change", ->
    set_team_leads($(this))
  set_team_leads($(".project-dropdown:last"))

set_team_leads = ($project_dropdown_obj) ->
  $team_leads_select = $project_dropdown_obj.parents("tr").find(".lead-dropdown")
  if $project_dropdown_obj.val() == ""
    $team_leads_select.empty()
    $team_leads_select.attr("disabled", true)
    return true
  $team_leads_select.removeAttr("disabled")
  $.getJSON "/projects/#{$project_dropdown_obj.val()}/leads.json", (data) ->
    $team_leads_select.empty()
    $team_leads_select.append('<option value></option>')
    for lead in data
      name = lead.display_name
      $team_leads_select.append("<option value=\"#{lead.id}\">"+name+'</option>')
