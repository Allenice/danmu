# global var

path = require 'path'

# auto increace id, get the next id
global.getNextId = (name, callback) ->
  global.db.collection('counters').findAndModify {_id: name}, [['_id', 'asc']], { $inc: { seq: 1 } }, {"new": true}, callback


# gloabl resumable obj
global.resumable = require('./modules/resumable-node.js')(path.join(__dirname, '/temp/'));

#
global.STATUS_SUCCESS = 'success'
global.STATUS_ERROR = 'error'

global.json_response = (res, status, data, message, page) ->
  res.set 'Content-Type', 'application/json'

  json = JSON.stringify({
    status: status,
    data: data,
    message: message,
    page: page
  })

  res.end json

module.exports = global