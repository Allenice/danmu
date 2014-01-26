#
$progress = $('#progress')
$progressBar = $progress.find('.progress-bar')
$uploadBtn = $('#upload-btn')
$videoName = $("#video-name")
$submitBth = $('#submit_btn')
$messagePanel = $("#message")

showError = (text) ->
  $messagePanel.removeClass('hidden alert-info').addClass('alert-danger').text text
showInfo = (text) ->
  $messagePanel.removeClass('hidden alert-danger').addClass('alert-info').text text

r = new Resumable({
  target: '/upload'
  chunkSize: 1*1024*1024,
  simultaneousUploads: 4,
  testChunks: false,
  throttleProgressCallbacks: 1,
  maxFiles:1,
  fileType: ['mp4'],
  fileTypeErrorCallback: (file, errors) ->
    showError '请上传MP4格式的视频!'
})





if !r.support
  $("#upload-form").hide()
  showError '您现在用的浏览器不支持该功能!'
else
  r.assignDrop $('#upload-form')[0]
  r.assignBrowse $('#upload-btn')[0]

  r.on 'fileAdded', (file) ->
    $messagePanel.addClass('hidden')
    $progress.removeClass('hidden')
    $uploadBtn.parent().addClass('hidden')
    r.upload()


  r.on 'pause', ()->
    # todo

  r.on 'complete', () ->
    # todo


  r.on 'fileSuccess', (file, message) ->
    $videoName.removeClass('hidden')
    $videoName.find('input[name=name]').val(file.fileName.substr(0, file.fileName.lastIndexOf('.')))

    $('input[name=filename]').val(file.fileName)

    # merge file
    $.post '/video/merge', {filename: file.fileName, identifier: file.uniqueIdentifier}, (res) ->
      if res.status == 'success'
        data = res.data || {}
        $('input[name=time]').val(data.time)
        $('input[name=format]').val(data.format)
        $('input[name=path]').val(data.path)
        $('input[name=poster]').val(data.poster)
        $('input[name=duration]').val(data.duration)

        if data.poster
          $("#thumb").removeClass('hidden').find('img').attr('src', '/video/thumbnail/'+data.poster)

        $submitBth.removeClass('hidden')
        $messagePanel.addClass('hidden')
      else
        showError '合并文件失败!'


  r.on 'fileError', (file, message) ->
    showError '上传出错'
    r.cancel()

  r.on 'fileProgress', (file, message) ->
    progress = Math.floor file.progress()*100
    $progressBar.css {'width': progress+'%'}
    $progressBar.find('span').text progress + '%'


  r.on 'cancel', ()->
    # todo

  r.on 'uploadStart', () ->
    # todo

  $submitBth.click () ->
    data = $("#upload-form").serialize()
    $.ajax {
      url: '/video/add',
      data: data,
      type: 'POST',
      dataType: 'json',
      beforeSend: () ->
        $submitBth.addClass('hidden')
      complete: () ->
        $submitBth.removeClass('hidden')
      success: (res) ->
        if res.status == 'success'
          window.location.href = '/video/av/'+res.data
        else
          console.log res.message
          showError '添加视频出错!'
    }
