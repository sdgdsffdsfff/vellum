md5 = (str) ->
  Buffer = require('buffer').Buffer
  buf = new Buffer 1024
  len = buf.write str, 0
  str = buf.toString 'binary', 0, len

  md5sum = require('crypto').createHash 'md5'
  md5sum.update str
  str = md5sum.digest 'hex'
  return str

unixtime = (date) ->
  date = new Date date
  return Math.floor date.getTime() / 1000


module.exports =
  md5: md5
  unixtime: unixtime
