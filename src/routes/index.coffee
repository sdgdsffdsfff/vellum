module.exports = (app) ->
  admin = require './admin'
  log = require './log'
  app.use log
  app.use admin
  return
