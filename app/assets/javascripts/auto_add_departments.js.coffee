$(document).on "ready", ->
  $("#employee_department_id").on "change", ->
    dropdown = $(this)
    parent_dept = dropdown.val()
    if parent_dept
      $.getJSON("departments/#{parent_dept}/sub_departments").success (data) ->
        html_to_append = "<select class='form-control' name='employee[department_id][]'>"
        html_to_append += "<option value></option>"
        for dept in data
          html_to_append += "<option value='#{dept.id}'>#{dept.name}</option>"
        html_to_append += "</select>"
        dropdown.after(html_to_append) if dropdown.next().length == 0 and data.length > 0
    else
      dropdown.nextAll().remove()
    