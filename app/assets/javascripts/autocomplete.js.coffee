$.widget "ui.test", $.ui.autocomplete, {
  _create: ->
    allVals = []
    $.each(this.element.children(), ->
      allVals.push($(this).text())
    )
    console.log allVals
    $("<input id='test-custom-autocomplete'>")
      .insertAfter(this.element)
      .addClass("form-control ui-autocomplete-input")
      .autocomplete({
       delay: 0,
       minLength: 0,
       source: allVals 
      })
    this.element.hide()
}


$ ->
  $("#test-autocomplete").test()
  #$("#test-autocomplete").autocomplete({"source": ["VISA", "Mastercard"]})
  #$("#test-autocomplete").on "change", ->
  #  alert $(this).val()
