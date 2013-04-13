#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap-transition
#= require twitter/bootstrap-carousel
#= require twitter/bootstrap-typeahead
#= require twitter/bootstrap-collapse
#= require twitter/bootstrap-modal
#= require jquery.expander
#= require jquery.maskedinput
#= require jquery.my_typeahead

$ ->
  setTimeout(
    -> window.scrollTo(0, 1),
    500)
  $('.expandable').expander()

  $('input[data-my-typeahead-source]').my_typeahead()

  $('#expanded-search #search_show_outdated').change ->
    if $(this).is(':checked')
      $('.show-outdated-desc').addClass('hidden')
    else
      $('.show-outdated-desc').removeClass('hidden')

  $('#expanded-search .clear-form').click (e)->
    $('#expanded-search').find(':input').each ->
      switch @type
        when 'password', 'select-multiple', 'select-one', 'text', 'textarea'
          $(this).val('')
        when 'checkbox', 'radio'
          @checked = false

  $('.to-top').live 'click', (e)->
    e.preventDefault()
    $('html, body').animate({scrollTop: 0}, 'medium')

  $('#blurbs-list tbody tr').click ->
    window.location = $(@).attr('data-url')

  $('#get-phone form').submit (e)->
    e.preventDefault()
    _phone = $(@).find('input.phone').val()
    _auth_token = $(@).find('input[name=authenticity_token]').val()
    $(@).find('input').attr('disabled', 'disabled')
    $('#verify-code .phone').val(_phone)
    $(@).prev('.alert').fadeOut()
    $.post $(@).attr('action'), {phone: _phone, authenticity_token: _auth_token}, 'script'

  $('.phone').mask('+375 99 999 99 99')
  $('.code').mask('aaaa')

  $('#verify-code form').submit (e)->
    $(@).find('input[type=submit]').attr('disabled', 'disabled')

  $('.show-similar-blurbs').live 'click', (e) ->
    e.preventDefault()
    $(@).closest('li').remove()
    $('.similar-blurbs').removeClass('hidden-phone')

  $('.expand-similar-blurbs').live 'click', (e) ->
    e.preventDefault()
    $(@).remove()
    $('.similar-blurbs').removeClass('short')

  $('#remove-ads').live 'click', ->
    $('.ad-container').remove()
    $.post $(@).data('url')
