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
$(document).ready ->
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
