settings = require '../config'
mongo = require('mongodb');

mongoDb = new mongo.Db(settings.db, new mongo.Server(settings.host, mongo.Connection.DEFAULT_PORT, {}))

mongoDb.open (err, db) ->
  if err
    console.log err
    return

  if global.db
    global.db.close()
    console.log 'Database disconnected!'

  global.db = db
  console.log 'Database connected!'

module.exports = mongoDb