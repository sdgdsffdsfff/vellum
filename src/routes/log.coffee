module.exports = (app) ->
  tool = require '../utils/tool'
  db = require '../utils/db'
  _ = require 'lodash'
  moment = require 'moment'

  app.post '/log/write/user', (req, res) ->
    if !req.body.debug
      res.send 'success'
    if req.body.appid and req.body.authcode
      sql = 'select * from application where appid = :appid and authcode = :authcode'
      db.query sql,
      appid: req.body.appid
      authcode: req.body.authcode,
      (err, rows) ->
        if err or _.isEmpty(rows)
          res.send 'application is not found'
          return false
        params =
          appid: req.body.appid
          type: req.body.type || ''
          createtime: moment().format 'X'
          operator: req.body.operator || 0
          content: req.body.content || ''
          level: req.body.level
        sql = 'insert into useraction_' + req.body.appid + ' (appid,type,createtime,operator,content,level) values (:appid,:type,:createtime,:operator,:content,:level)'
        db.query sql, params, (err, rows) ->
          if !err
            res.send 'success'
          else
            res.send 'error'
          return
        return
    else
      res.send 'appid or authcode is empty'
    return

  app.post '/log/write/sys', (req, res) ->
    if !req.body.debug
      res.send 'success'
    if req.body.appid and req.body.authcode
      sql = 'select * from application where appid = :appid and authcode = :authcode'
      db.query sql,
      appid: req.body.appid
      authcode: req.body.authcode,
      (err, rows) ->
        if err or _.isEmpty(rows)
          res.send 'application is not found'
          return false
        params =
          appid: req.body.appid
          createtime: moment().format 'X'
          content: req.body.content || ''
          level: req.body.level
        sql = 'insert into sysaction_' + req.body.appid + ' (appid,createtime,content,level) values (:appid,:createtime,:content,:level)'
        db.query sql, params, (err, rows) ->
          if !err
            res.send 'success'
          else
            res.send 'error'
          return
        return
    else
      res.send 'appid or authcode is empty'
    return

  return
