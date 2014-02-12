# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require angular
#= require jquery
#= require jquery.ui.effect-blind
#= require jquery_ujs
#= require bootstrap
#= require jquery.autosize.min
#= require expand_collapse_panels
#= require modernizr

$(document).ready ->
  $("form#resources-per-page select").on "change", ->
    $(this).parent("form").submit()
  $('textarea').autosize({append: "\n"})
  $("#help-btn").tooltip()
  $("form").submit ->
    valid = "true"
    $(this).find("[required]").each (index) ->
      if $(this).val() == ""
        $(this).parent("div.form-group").addClass("has-error")
        valid = "false"
      else
        $(this).parent("div.form-group").removeClass("has-error")
    $(this).find("[data-loading-text]").button('loading') if valid == "true"
  unless Modernizr.inputtypes.time
    $("input[type=time]").each (index) ->
      match = /(\d{2}):(\d{2}):\d{2}\.\d{3}/.exec(String($(this).val()))
      if match
        match[1] = parseInt(match[1])
        amorpm = if (match[1] >= 12 and match != 24) then "PM" else "AM"
        if match[1] > 12
          match[1] -= 12
        else if parseInt(match[1]) == 0
          match[1] = 12
        $(this).val("#{match[1]}:#{match[2]} #{amorpm}")
