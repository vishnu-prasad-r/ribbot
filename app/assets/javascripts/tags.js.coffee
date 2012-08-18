jQuery ->
  $('#tags tbody').sortable(
    axis: 'y'
    handle: '.handle'
    update: ->
      $.post($('#tags').data('update-url'), $(this).sortable('serialize'))
    helper: (e, tr) ->
      $originals = tr.children()
      $helper = tr.clone()
      $helper.children().each (index) ->
        $(this).width($originals.eq(index).width())
      $helper
  )
  
  $('#tags').hide() if $('#tags tbody tr').length == 0
  
  $('#tags .edit-tag-link').live 'click', (e) ->
    tr = $(this).parents('tr')
    tr.find('.show').hide()
    tr.find('.edit').fadeIn('fast')
    
  $('#tags .cancel-edit-tag-link').live 'click', (e) ->
    tr = $(this).parents('tr')
    tr.find('.edit').hide()
    tr.find('.show').fadeIn('fast')
    
  $('.post-form .tag-link, .comment-form .tag-link').click (e) ->
    $(this).toggleClass('active')
    checkbox = $(this).siblings('.tag-checkbox')
    checkbox.attr('checked', !checkbox.attr('checked'))
    false

  $('.twit-link').click (e) ->
    form = $(this).parents('form')
    checkbox = $(this).siblings('.twit-checkbox')
    if checkbox.attr('checked')
      ctl = encodeURIComponent(form.attr('action'))
      form.attr('action', '/auth/twitter?callback=twit&form_action=' + ctl + "&redirect_action=" + $(this).attr('data-action'))
    else
      ctl = form.attr('action').replace(/.*form_action=([^&]+)&.*/i, "$1")
      form.attr('action', decodeURIComponent(ctl))

  $('.twit-submit').click (e) ->
    form = $(this).parents('form')
    checkbox = form.find('.twit-checkbox')
    if checkbox.attr('checked')
      action = form.attr('action')
      form.attr('action', action + '&' + form.serialize())

