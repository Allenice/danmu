// Generated by CoffeeScript 1.7.1
(function() {
  var $barrage, $info, $videoWrap, barrages, flag, path, preTime, socket, top, vid, videoPlayer, winResize;

  $('body').css({
    'background-color': '#333'
  });

  path = window.location.pathname;

  vid = parseInt(path.substr(path.lastIndexOf('/') + 1));

  barrages = [];

  if (isNaN(vid)) {
    window.location.href = '/404.html';
  }

  $barrage = $("#barrage");

  $videoWrap = $('#video-wrap');

  $info = $('#info');

  $info.find('.list-group-item').each(function(index, html) {
    var $item, item;
    $item = $(html);
    item = {
      'time': $item.data('time'),
      'duration': $item.data('duration'),
      'content': $item.attr('title')
    };
    return barrages.push(item);
  });

  videojs.options.flash.swf = '/lib/videojs/video-js.swf';

  videoPlayer = videojs('video');

  preTime = 0;

  flag = 0;

  top = 0;

  videoPlayer.on('timeupdate', function(e) {
    var $item, barrage, curTime, _i, _len;
    curTime = parseInt(videoPlayer.currentTime());
    if (curTime === preTime) {
      return;
    }
    for (_i = 0, _len = barrages.length; _i < _len; _i++) {
      barrage = barrages[_i];
      if (barrage.duration === curTime) {
        $item = $('<div class="barrage">' + barrage.content + '</div>');
        $item.appendTo($("#video"));
        $item.css({
          'top': top + 'px'
        });
        top = top + 30;
        flag++;
        if (flag > 5) {
          flag = 0;
          top = 0;
        }
        $item.animate({
          'left': '-50%'
        }, 15000, 'linear', function() {
          return $(this).remove();
        });
      }
    }
    return preTime = curTime;
  });

  winResize = function(e) {
    var height, width;
    width = $videoWrap.width();
    height = 9 / 16 * width;
    $videoWrap.height(height);
    return $info.find('.panel-body').css({
      'max-height': height,
      'overflow': 'auto'
    });
  };

  winResize();

  $(window).on('resize', function(e) {
    return winResize(e);
  });

  socket = io.connect('/video');

  socket.on('connected', function() {
    return socket.emit('connected', {
      id: vid
    });
  });

  socket.on('connected' + vid, function(data) {
    return $('#p-count').text(data.count);
  });

  socket.on('barrage' + vid, function(barrage) {
    var $li;
    barrages.push(barrage);
    $li = $('<li class="list-group-item" data-duration="' + barrage.duration + '" title="' + barrage.content + '">' + barrage.content + '</li>');
    $li.css({
      'height': '30px',
      'line-height': '30px',
      'padding': '0 10px',
      'overflow': 'hidden'
    });
    $info.find('.list-group').prepend($li);
    return $('#c-count').text(barrages.length);
  });

  window.onbeforeunload = function(e) {
    socket.emit('disconnected' + vid);
  };

  $barrage.find('input').keyup(function(e) {
    var barrage;
    if (e.keyCode === 13 && $.trim($(this).val())) {
      barrage = $(this).val();
      $(this).val('');
      return socket.emit('barrage' + vid, {
        duration: parseInt(videoPlayer.currentTime() + 1),
        content: barrage
      });
    }
  });

}).call(this);

//# sourceMappingURL=video.map
