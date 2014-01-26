module.exports = (io) ->

  escape = require 'escape-html'
  VideoModel = require '../model/Video'

  connectCount = {
    'i0': 0
  }

  global.video_sockets = video_sockets = io.of('/video')

  video_sockets.on 'connection', (socket) ->
    global.private_video_sockets = socket
    connectCount['i0']++

    # server send connected info to client
    socket.emit 'connected'

    # server get info from client after connected
    socket.on 'connected', (data) ->
      vid = data.id
      vindex = 'i'+vid

      if !connectCount[vindex]
        connectCount[vindex] = 0
      connectCount[vindex]++

      # Tell the client that server has connected and pass the connection count of current video to client.
      video_sockets.emit 'connected'+vid, {count: connectCount[vindex]}

      socket.on 'disconnected'+vid, () ->
        connectCount[vindex]--
        video_sockets.emit 'connected'+vid, {count: connectCount[vindex]}

      socket.on 'barrage'+vid, (barrage)->
        barrage.content = escape barrage.content
        barrage.time  = (new Date()).getTime()
        VideoModel.addBarrage vid, barrage, (err) ->
          video_sockets.emit 'barrage'+vid, barrage

    video_sockets.emit 'total connection', {count: connectCount['i0']}

    socket.on 'disconnect', ()->
      connectCount['i0']--
      video_sockets.emit 'someone connect', {count: connectCount['i0']}
      return

    return



  return