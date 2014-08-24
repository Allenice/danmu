#
$('body').css {'background-color': '#333'}

path = window.location.pathname
vid = parseInt path.substr(path.lastIndexOf('/')+1)
barrages = []

if isNaN(vid)
  window.location.href = '/404.html'

$barrage = $("#barrage")
$videoWrap = $('#video-wrap')
$info = $('#info')

$info.find('.list-group-item').each (index, html) ->
    $item = $(html)
    item = {
      'time': $item.data('time'),
      'duration': $item.data('duration'),
      'content': $item.attr('title')
    }
    barrages.push(item)

# video player
videojs.options.flash.swf = '/lib/videojs/video-js.swf'

videoPlayer = videojs 'video'
preTime = 0
flag = 0
top = 0

videoPlayer.on 'timeupdate', (e)->
  curTime = parseInt(videoPlayer.currentTime())
  if curTime == preTime
    return

  for barrage in barrages
    if barrage.duration == curTime
      $item = $('<div class="barrage">'+barrage.content+'</div>')
      $item.appendTo($("#video"))
      $item.css {'top': top+'px'}

      top = top + 30
      flag++
      if flag>5
        flag = 0
        top = 0

      $item.animate({'left': '-50%'}, 15000, 'linear', ()->
        $(this).remove()
      )
  preTime = curTime

# adjust the video container while window size change
winResize = (e) ->
  width = $videoWrap.width()
  height = 9/16 * width
  $videoWrap.height height
  $info.find('.panel-body').css {'max-height': height, 'overflow': 'auto'}

winResize()

$(window).on 'resize', (e) ->
  winResize(e)


# connect to server

socket = io.connect('/video')

socket.on 'connected', () ->
  socket.emit 'connected', {id: vid}

socket.on 'connected'+vid, (data)->
  $('#p-count').text data.count

socket.on 'barrage'+vid, (barrage)->
  barrages.push(barrage)
  $li = $('<li class="list-group-item" data-duration="'+barrage.duration+'" title="'+barrage.content+'">'+barrage.content+'</li>')
  $li.css {'height': '30px', 'line-height': '30px', 'padding': '0 10px', 'overflow': 'hidden'}
  $info.find('.list-group').prepend($li)
  $('#c-count').text(barrages.length)


$barrage.find('input').keyup (e) ->
  if e.keyCode == 13
    barrage = $(this).val()
    $(this).val('')
    socket.emit 'barrage'+vid, {duration: parseInt(videoPlayer.currentTime() + 1), content:barrage}

