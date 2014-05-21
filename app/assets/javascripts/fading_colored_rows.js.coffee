$ ->
  for type in ["warning","success"]
    $("tr.#{type}").removeClass("#{type}")