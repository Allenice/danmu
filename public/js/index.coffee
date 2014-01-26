# index.js
$ ()->

  getUrlValue = (name) ->
    return decodeURI((RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||['',null])[1])

  vid  = getUrlValue('id') || 0

  socket = io.connect('/video')

  socket.on 'connected', () ->
    socket.emit 'connected', {id: vid}

  socket.on 'new message'+vid, (msg) ->
    $item = $ "<div class=\"item\">#{msg}</div>"
    $('#container .messages').append $item
    return

  $("#container input:text").keyup (e)->
    if e.keyCode == 13
      socket.emit 'send'+vid, $(this).val()
      $(this).val('')
    return

  socket.on 'someone connect'+vid, (data)->
    $('#count').text data.count

  window.onbeforeunload = (e) ->
    socket.emit 'someone disconnected'+vid, {id: vid}
    return

  return