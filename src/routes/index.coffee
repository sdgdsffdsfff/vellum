module.exports = (app) ->
  admin = require './admin'
  log = require './log'
  log app
  admin app
  return
