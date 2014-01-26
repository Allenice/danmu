
# video model

class Video
  constructor: (@video) ->
    @id = @video.id
    @name = @video.name
    @path = @video.path
    @format = @video.format
    @time = @video.time
    @poster = @video.poster
    @duration = @video.duration
    @play_count = @video.play_count
    @barrage = @video.barrage
    @barrage_count = @video.barrage_count

  save: (callback) ->

    callback = callback || () ->

    if global.db
      global.db.collection 'video', (err, collection) =>
        if err
          console.log err
          return callback err
        collection.insert @video, (err, v) =>
          if err
            return callback err
          callback err, this

  incPlayCount: () ->
    if global.db
      global.db.collection 'video', (err, collection) =>
        if collection
          collection.update({id: this.id}, {"$inc": {"play_count": 1}} )

  @findOne: (id, callback) ->
    callback = callback || () ->

    if global.db
      global.db.collection 'video', (err, collection) ->
        if err
          console.log err
          return callback err
        collection.findOne {id: parseInt(id)}, (err, v) ->
          if err
            return callback err,v
          callback err, new Video(v)

  @find: (from, to, callback) ->
    callback = callback || () ->

    if global.db
      global.db.collection 'video', (err, collection) ->
        if err
          console.log err
          return callback err
        collection.find({}, {limit: to, skip: from,fields:{'barrage':0}, sort: [['time', 'desc'], ['barrage.time','desc']]}).toArray (err, result)->
          if err
            return callback err, result

          videos = []
          for video in result
            videos.push new Video(video)

          callback err, videos

  @addBarrage: (id, barrage, callback) ->
    callback = callback || () ->
    callback()
    if id && barrage && global.db
      global.db.collection 'video', (err, collection) =>
        if err
          return callback err
        collection.update {id:id}, {"$push": {"barrage": barrage}}
        collection.update {id:id}, {"$inc": {"barrage_count": 1}}


module.exports = Video
