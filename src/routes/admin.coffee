q = require 'q'
moment = require 'moment'
applicationModel = require '../model/application'
router = require('express').Router()

router.use (req, res, next) ->
  reg = /^\/admin/
  if reg.test(req.url) and req.url isnt '/admin' and req.url isnt '/admin/login'
    if not req.session.islogin
      res.redirect '/admin'
      return false
  next()
  return

router.get '/admin', (req, res) ->
  res.redirect '/admin/app' if req.session.islogin
  res.render 'login'
  return

router.post '/admin/login', (req, res) ->
  if req.body.username and req.body.password
    adminModel = require '../model/admin'
    adminModel
      .checkLogin req.body.username, req.body.password
      .then (data) ->
        req.session.islogin = 1
        res.redirect '/admin/app'
        return
      .catch (err) ->
        res.redirect '/admin'
        return
  return

router.get '/admin/app', (req, res) ->
  applicationModel
    .getList()
    .then (data) ->
      res.render 'app',
      data:data
      return
  return

router.get '/admin/app/add', (req, res) ->
  res.render 'app-add'
  return

router.post '/admin/app/add', (req, res) ->
  applicationModel
    .add(req.body.name)
    .then (data) ->
      res.redirect '/admin/app'
      return
    .catch (err) ->
      res.send '添加失败'
      return
  return

router.get '/admin/app/setting/:appid', (req, res) ->
  appid = req.params.appid
  getPromise = applicationModel.get(appid)
  getActionPromise = applicationModel.getAction(appid)

  q.all([getPromise, getActionPromise])
    .then (data) ->
      res.render 'app-setting',
      data: data[0][0]
      type: data[1]
      return
    .catch (err) ->
      res.status = 500
      res.send '500 Internal server error'
      return
  return

router.post '/admin/actiontype/add', (req, res) ->
  if req.body.appid and req.body.name and req.body.callname
    applicationModel
      .addAction(req.body.appid, req.body.name, req.body.callname)
      .then (data) ->
        res.json data.insertId
        return
      .catch (err) ->
        res.json 0
        return
  else
    res.json 0
  return

router.post '/admin/actiontype/del', (req, res) ->
  if req.body.id
    applicationModel
      .delAction(req.body.id)
      .then (data) ->
        res.json 1
        return
      .catch (err) ->
        res.json 0
        return
  else
    res.json 0
  return

router.get '/admin/log', (req, res) ->
  applicationModel
    .getList()
    .then (data) ->
      res.render 'log',
      data: data
      return
  return

router.get '/admin/log/:type/list/:appid', (req, res) ->
  type = req.params.type
  logModel = require '../model/log'
  sqlwhere = ''
  if req.query.search
    search = req.query.search
    where = []
    where.push "type = '#{search['type']}'" if search['type'] isnt '' if type is 'user'
    where.push "operator = '#{search['operator']}'" if search['operator'] isnt '' if type is 'user'
    where.push "content like '%#{search['content']}%'" if search['content'] isnt ''
    where.push "level = '#{search['level']}'" if search['level'] isnt ''
    where.push "createtime >= '#{moment(search['starttime']).format('X')}'" if search['starttime'] isnt ''
    where.push "createtime <= '#{parseInt(moment(search['endtime']).format('X'))}'" if search['endtime'] isnt ''
    sqlwhere = ' where ' + where.join ' and ' if where != []
  pagesize = 20
  currentpage = req.query.currentpage || 1
  start = (currentpage - 1) * pagesize
  q = require 'q'
  getApp = applicationModel.get req.params.appid
  getType = applicationModel.getAction req.params.appid
  getLogCount = logModel.getCount req.params.appid, sqlwhere, type
  getLogData = logModel.getData req.params.appid, sqlwhere, start, pagesize, type

  q.all([getApp, getLogCount, getLogData, getType])
    .then (data) ->
      res.render "log-list-#{type}",
        get: req.query.search || {}
        appid: req.params.appid
        appname: data[0][0]['name']
        data: data[2]
        actiontype: data[3]
        pagecount: data[1]
        pagesize: pagesize
        currentpage: currentpage
        loglevel: logModel.loglevel
      return
    .catch (err) ->
      res.status 404
      res.send 'Not Found'
      return
  return

router.get '/admin/readme', (req, res) ->
  res.render 'readme'
  return

module.exports = router
