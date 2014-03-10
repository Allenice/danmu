
# video controller
os_path = require 'path'
fs = require 'fs'
settings = require '../config'
Video = require '../model/Video'
util = require '../modules/util'
escape = require 'escape-html'

module.exports = (app) ->

  # video list
  app.get '/video', (req, res) ->
    Video.find 0, 0, (err, result)->
      if err
        res.redirect '/404.html'
      else
        for video in result
          video.time = util.getFormatDate(video.time)
          if !video.play_count
            video.play_count = 0
          if !video.barrage_count
            video.barrage_count = 0

        res.render 'video_list', {videos: result, title: '视频列表', navAction: {url: '/video/add', text: '上传视频'}}

  # view video
  app.get '/video/av/:id', (req, res) ->
    id = req.params.id
    Video.findOne id, (err, v) ->
      if err
        res.redirect '/404.html'
        return
      v.incPlayCount()
      if !v.barrage_count
        v.barrage_count = 0

      if v.barrage
        v.barrage.sort (a, b) ->
          return  b.time-a.time
      res.render 'video', {video: v, title: v.name}

  # add a video
  app.get '/video/add', (req, res) ->
    res.render 'add_video', {title: 'Add Video', navAction:{url: '/video', text: '返回列表'}}

  # add a video action
  app.post '/video/add', (req, res) ->
    video = {
      name : escape(req.body.name),
      path : req.body.path,
      format : req.body.format,
      time : req.body.time,
      poster : req.body.poster,
      duration : req.body.duration
    }

    getNextId 'video_id', (err, result) ->
      if err
        json_response res, 'error', null, err.message
      video.id = result.seq
      video = new Video(video)
      video.save (err, v)->
        if err
          json_response res, 'error', null, err.message
        json_response(res, 'success', v.id)


  #video merge
  app.post '/video/merge', (req, res) ->
    filename = req.body.filename
    identifier = req.body.identifier

    util = require '../modules/util'
    util.mergeFile filename, identifier, (err, path, format, time) ->
      if err
        json_response res, 'error', null, err.message
      else
        # screenshot
        ffmpeg = require 'fluent-ffmpeg'
        videoPath = os_path.join(__dirname, '../uploads/'+path)
        thumbPath = os_path.join(__dirname, '../uploads/thumb/')
        video = {path: path, format: format, time: time}

        proc = new ffmpeg {source: videoPath}
        proc.setFfmpegPath settings.ffmpegPath
        proc.withSize('150x150').takeScreenshots {count:1, timemarks: ['10%'], filename: '%f_thumb_%wx%h_%i'}, thumbPath, (err, fileName) ->
          if !err
            video.poster = fileName

          # get duration
          meta = new ffmpeg.Metadata videoPath, (info, err) ->
            if !err
              video.duration = info.durationraw.substr(0, info.durationraw.lastIndexOf('.'))
            json_response res, 'success', video


  # video thumbnail
  app.get '/video/thumbnail/:filename?*', (req, res) ->
    thumbPath =  os_path.join __dirname, '../uploads/thumb/'+req.params.filename
    defaultPath = os_path.join __dirname, '../uploads/thumb/thumb_default.png'
    fs.exists thumbPath, (exists) ->
      if exists
        res.sendfile thumbPath
      else
        res.sendfile defaultPath


  # video convert
  app.post '/video/convert', (req, res) ->
    res.end 'forbid'

    ffmpeg = require 'fluent-ffmpeg'

    sourcePath = req.body.video_path

    console.log sourcePath

    if !sourcePath
      json_response res, 'error', null, 'File not found when converting!'
      return

    sourceFormat = sourcePath.substr sourcePath.lastIndexOf('.')+1
    if sourceFormat == 'mp4'
      json_response res, 'success', {'format': 'mp4', 'path': sourcePath}
      return

    tempPath = targetPath = sourcePath.substr(0, sourcePath.lastIndexOf('.'))+'.mp4'

    uploadPath =  os_path.join(__dirname, '../uploads/')
    sourcePath = os_path.join(uploadPath, sourcePath)
    targetPath = os_path.join(uploadPath, targetPath)

    proc = new ffmpeg {source: sourcePath, timeout: 3600}

    proc.setFfmpegPath settings.ffmpegPath

    proc.withVideoCodec('libx264').onProgress((info)->
      private_video_sockets.emit 'convert progress', info

    ).toFormat('mp4').saveToFile targetPath, (stdout, stderr) ->
        json_response res, 'success', {'format': 'mp4', 'path': tempPath}
