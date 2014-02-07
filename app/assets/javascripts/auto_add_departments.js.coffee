$(document).on "ready", ->
  $("[name=employee\\[department_id\\]\\[\\]]").on "change", ->
    addSubDeptSelect($(this))
    
addSubDeptSelect = (obj) ->
  dropdown = obj
  parent_dept = dropdown.val()
  if parent_dept
    $.getJSON("/departments/#{parent_dept}/sub_departments").success (data) ->
      html_to_append = "<select class='form-control' name='employee[department_id][]'>"
      html_to_append += "<option value></option>"
      for dept in data
        html_to_append += "<option value='#{dept.id}'>#{dept.name}</option>"
      html_to_append += "</select>"
      if data.length > 0
        dropdown.nextAll().remove()
        select_to_append = $(html_to_append)
        select_to_append.on "change", ->
          addSubDeptSelect($(this))
        dropdown.after(select_to_append)
  else
    dropdown.nextAll().remove()