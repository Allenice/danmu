
moment = require 'moment'

exports.mergeFile = (filename, identifier, callback) ->
  fs = require 'fs'
  path = require 'path'

  time = (new Date()).getTime()
  format = filename.substr(filename.lastIndexOf('.')+1)
  saveName = time + '.' + format
  saveFullName = path.join(global.resumable.uploadDir, saveName)

  fs.writeFile saveFullName,'', {flag: 'w+'}, (err) ->
    if err
      callback err
      return

    mergeFile = (chunkNum) ->
      chunkFileName = path.join global.resumable.temporaryFolder, '/resumable-'+identifier+'.'+chunkNum
      fs.exists chunkFileName, (exists) ->
        if exists
          fs.readFile chunkFileName, (err, data) ->
            if err
              callback err
              return

            fs.appendFile saveFullName, data, (err) ->
              if err
                callback err
                return
              fs.unlink chunkFileName, (err) ->
              mergeFile(++chunkNum)
        else
          callback null, saveName, format, time
          console.log 'file: ' + chunkFileName + ' not exists'
        return
      return

    mergeFile(1)

exports.getFormatDate = (time) ->
  date = moment(parseFloat(time))
  second = date.get('second')
  if second < 10
    second = '0' + second
  return date.get('year')+'-'+(date.get('month')+1)+'-'+date.get('date')+' '+date.get('hour')+':'+date.get('minute')+':'+second