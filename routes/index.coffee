

module.exports = (app) ->

  video_route = require './video'
  video_route(app)

  # index
  app.get '/', (req, res) ->
    res.redirect '/video'

  app.get '/404.html', (req, res) ->
    res.end '404 error'

  # install-- init the counter
  app.get '/install', (req, res) ->

    if !global.db
      res.end 'install failed, Database is not connected!'
      return

    global.db.collection('counters').insert [
      {
        _id: 'video_id',
        seq: 1000
      },
      {
        _id: 'barrage_id',
        seq: 0
      }
    ], (err, item) ->
      if err
        res.end err.message
      else
        res.end 'install successfully!'

  app.get '/resources/:filename', (req, res) ->
    path = require 'path'
    res.sendfile path.join __dirname, '../uploads/'+req.params.filename


  # upload
  app.post '/upload', (req, res) ->
    global.resumable.post req, (status, filename, original_filename, identifier) ->
      res.send status