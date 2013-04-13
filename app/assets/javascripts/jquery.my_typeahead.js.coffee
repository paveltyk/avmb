jQuery.fn.my_typeahead = ->
  return $(@).each ->
    input = $(@)
    selector = input.data('my-typeahead-source')
    autocoplete_json = $(selector).data('json')

    input.typeahead
        source: autocoplete_json
        items: 24
