module.exports = (app) ->
  db = require '../utils/db'
  tool = require '../utils/tool'
  _ = require 'lodash'
  loglevel =
    1: 'debug'
    2: 'info'
    3: 'warning'
    4: 'error'
    5: 'fatal'
  moment = require 'moment'

  app.use (req, res, next) ->
    reg = /^\/admin/
    if reg.test req.url and req.url != '/admin' and req.url != '/admin/login'
      if !req.session.islogin
        res.redirect '/admin'
    next()
    return

  app.get '/admin', (req, res) ->
    res.redirect '/admin/app' if req.session.islogin
    res.render 'login'
    return

  app.post '/admin/login', (req, res) ->
    if req.body.username and req.body.password
      sql = 'select id from admin where username = :username and password = :password'
      db.query sql,
      username: req.body.username
      password: tool.md5(req.body.password),
      (err, rows) ->
        if _.isEmpty rows or err
          res.direct '/admin'
          return false
        req.session.islogin = 1
        res.redirect '/admin/app'
        return false
    else
      res.redirect '/admin'
    return

  app.get '/admin/app', (req, res) ->
    sql = 'select * from application'
    db.query sql, (err, rows) ->
      if !err
        res.render 'app',
        data:rows
      return
    return

  app.get '/admin/app/add', (req, res) ->
    res.render 'app-add'
    return

  app.post '/admin/app/add', (req, res) ->
    appid = String moment().format 'X'
    authcode = (tool.md5 appid + Math.random() * 1000).substr 0,16
    createsyssqltpl = "CREATE TABLE `sysaction_##id` (`id` int(11) unsigned NOT NULL AUTO_INCREMENT, `appid` varchar(255) NOT NULL DEFAULT '' COMMENT '应用ID', `createtime` int(10) NOT NULL COMMENT '创建时间', `content` text NOT NULL COMMENT '日志内容', `level` tinyint(1) NOT NULL COMMENT '日志级别', PRIMARY KEY (`id`) ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='系统日志表';"
    createusersqltpl = "CREATE TABLE `useraction_##id` (`id` int(11) unsigned NOT NULL AUTO_INCREMENT, `appid` varchar(255) NOT NULL DEFAULT '' COMMENT '应用ID', `type` varchar(255) NOT NULL DEFAULT '' COMMENT '操作类型', `createtime` int(10) NOT NULL COMMENT '创建时间', `operator` int(11) NOT NULL COMMENT '操作人', `content` text NOT NULL COMMENT '日志内容', `level` tinyint(1) NOT NULL COMMENT '日志级别', PRIMARY KEY (`id`) ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='用户日志表';"
    sql = "insert into application (appid,name,authcode) values (:appid,:name,:authcode)"
    db.query sql,
    name: req.body.name
    appid: appid
    authcode: authcode,
    (err, rows) ->
      if !err
        db.query createsyssqltpl.replace '##id', appid
        db.query createusersqltpl.replace '##id', appid
        res.redirect '/admin/app'
        return false
      res.send '添加失败'
      return
    return

  app.get '/admin/app/setting/:appid', (req, res) ->
    appid = req.params.appid
    sql = 'select * from application where appid = :appid limit 1'
    db.query sql,
    appid: appid,
    (err, rows) ->
      if !err
        if _.isEmpty rows
          res.status 404
          res.send '应用不存在'
        sql = 'select * from actiontype where appid = :appid'
        db.query sql,
        appid: appid,
        (err, result) ->
          res.render 'app-setting',
          data: rows[0]
          type: result
          return
        return
    return

  app.post '/admin/actiontype/add', (req, res) ->
    if req.body.appid and req.body.name and req.body.callname
      sql = 'insert into actiontype (appid,name,callname) values (:appid,:name,:callname)'
      db.query sql,
      appid: req.body.appid
      name: req.body.name
      callname: req.body.callname,
      (err, rows) ->
        if !err
          res.json rows.insertId
        else
          res.json 0
        return
      return
    else
      res.json 0
    return

  app.post '/admin/actiontype/del', (req, res) ->
    if req.body.id
      sql = 'delete from actiontype where id = :id'
      db.query sql,
      id: req.body.id,
      (err, rows) ->
        if !err
          res.json 1
        else
          res.json 0
        return
    else
      res.json 0
    return

  app.get '/admin/log', (req, res) ->
    sql = 'select * from application'
    db.query sql, (err, rows) ->
      if !err
        res.render 'log',
        data: rows
      return
    return

  app.get '/admin/log/user/list/:appid', (req, res) ->
    sqlwhere = ''
    if req.query.search
      search = req.query.search
      where = []
      where.push "content like '%" + search['content'] + "%'" if search['content'] != ''
      where.push "operator = '" + search['operator'] + "'" if search['operator'] != ''
      where.push "type = '" + search['type'] + "'" if search['type'] != ''
      where.push "level = '" + search['level'] + "'" if search['level'] != ''
      where.push "createtime >= '" + moment(search['starttime']).format('X') + "'" if search['starttime'] != ''
      where.push "createtime <= '" + parseInt(moment(search['endtime']).format('X')) + "'" if search['endtime'] != ''
      sqlwhere = ' where ' + where.join ' and ' if where != []
    pagesize = 20
    currentpage = req.query.currentpage || 1
    start = (currentpage - 1) * pagesize
    q = require 'q'
    getApp = (->
      deferred = q.defer()
      sql = 'select name from application where appid = :appid'
      db.query sql,
      appid: req.params.appid,
      (err, rows) ->
        if !err
          deferred.resolve rows[0]['name']
        deferred.reject err
        return
      return deferred.promise
    )()

    getType = (->
      deferred = q.defer()
      sql = "select * from actiontype where appid = :appid"
      db.query sql,
      appid: req.params.appid,
      (err, rows) ->
        if !err
          deferred.resolve rows
          deferred.reject err
        return
      return deferred.promise
    )()

    getLogCount = (->
      deferred = q.defer()
      sql = 'select count(id) as count from useraction_' + req.params.appid + sqlwhere
      db.query sql,
      appid: req.params.appid,
      (err, rows) ->
        if !err
          deferred.resolve rows[0]['count']
        deferred.reject err
        return
      return deferred.promise
    )()

    getLogData = (->
      deferred = q.defer()
      sql = 'select * from useraction_' + req.params.appid + sqlwhere + ' order by id desc limit ' + start + ',' + pagesize
      db.query sql,
      appid: req.params.appid,
      (err, rows) ->
        if !err
          _.forEach rows, (v, k) ->
            v['createtime'] = moment.unix(v['createtime']).format 'YYYY-MM-DD HH:mm:ss'
            return
          deferred.resolve rows
        deferred.reject err
        return
      return deferred.promise
    )()

    q.all([getApp, getLogCount, getLogData, getType]).then((data) ->
      res.render 'log-list-user',
      get: req.query.search || {}
      appid: req.params.appid
      appname: data[0]
      data: data[2]
      actiontype: data[3]
      pagecount: data[1]
      pagesize: pagesize
      currentpage: currentpage
      loglevel: loglevel
      return
      ).catch (err) ->
        res.status 404
        res.send 'Not Found'
        return
    return

  app.get '/admin/log/sys/list/:appid', (req, res) ->
    sqlwhere = ''
    if req.query.search
      search = req.query.search
      where = []
      where.push "content like '%" + search['content'] + "%'" if search['content'] != ''
      where.push "level = '" + search['level'] + "'" if search['level'] != ''
      where.push "createtime >= '" + moment(search['starttime']).format('X') + "'" if search['starttime'] != ''
      where.push "createtime <= '" + parseInt(moment(search['endtime']).format('X')) + "'" if search['endtime'] != ''
      sqlwhere = ' where ' + where.join ' and ' if where != []
    pagesize = 20
    currentpage = req.query.currentpage || 1
    start = (currentpage - 1) * pagesize
    q = require 'q'
    getApp = (->
      deferred = q.defer()
      sql = 'select name from application where appid = :appid'
      db.query sql,
      appid: req.params.appid,
      (err, rows) ->
        if !err
          deferred.resolve rows[0]['name']
        deferred.reject err
        return
      return deferred.promise
    )()

    getType = (->
      deferred = q.defer()
      sql = "select * from actiontype where appid = :appid"
      db.query sql,
      appid: req.params.appid,
      (err, rows) ->
        if !err
          deferred.resolve rows
          deferred.reject err
        return
      return deferred.promise
    )()

    getLogCount = (->
      deferred = q.defer()
      sql = 'select count(id) as count from sysaction_' + req.params.appid + sqlwhere
      db.query sql,
      appid: req.params.appid,
      (err, rows) ->
        if !err
          deferred.resolve rows[0]['count']
        deferred.reject err
        return
      return deferred.promise
    )()

    getLogData = (->
      deferred = q.defer()
      sql = 'select * from sysaction_' + req.params.appid + sqlwhere + ' order by id desc limit ' + start + ',' + pagesize
      db.query sql,
      appid: req.params.appid,
      (err, rows) ->
        if !err
          _.forEach rows, (v, k) ->
            v['createtime'] = moment.unix(v['createtime']).format 'YYYY-MM-DD HH:mm:ss'
            return
          deferred.resolve rows
        deferred.reject err
        return
      return deferred.promise
    )()

    q.all([getApp, getLogCount, getLogData, getType]).then((data) ->
      res.render 'log-list-sys',
      get: req.query.search || {}
      appid: req.params.appid
      appname: data[0]
      data: data[2]
      actiontype: data[3]
      pagecount: data[1]
      pagesize: pagesize
      currentpage: currentpage
      loglevel: loglevel
      return
      ).catch (err) ->
        res.status 404
        res.send 'Not Found'
        return
    return

  app.get '/admin/readme', (req, res) ->
    res.render 'readme'
    return

  return
