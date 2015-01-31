router = require('express').Router()
applicationModel = require '../model/application'
logModel = require '../model/log'

router.post '/log/write/user', (req, res) ->
  if not req.body.debug
    res.send 'success'
  if req.body.appid and req.body.authcode
    applicationModel
      .checkAuthcode req.body.appid, req.body.authcode
      .then (data) ->
        logModel
          .addUserLog req.body.appid, req.body.type, req.body.operator, req.body.content, req.body.level
          .then (data) ->
            res.send 'success'
            return
          .catch (err) ->
            res.send 'error'
            return
        return
      .catch (err) ->
        res.send 'application is not found'
        return false
  else
    res.send 'appid or authcode is empty'
  return

router.post '/log/write/sys', (req, res) ->
  if not req.body.debug
    res.send 'success'
  if req.body.appid and req.body.authcode
    applicationModel
      .checkAuthcode req.body.appid, req.body.authcode
      .then (data) ->
        logModel
          .addSysLog req.body.appid, req.body.content, req.body.level
          .then (data) ->
            res.send 'success'
            return
          .catch (err) ->
            res.send 'error'
            return
      .catch (err) ->
        res.send 'application is not found'
        return false
  else
    res.send 'appid or authcode is empty'
  return

module.exports = router
