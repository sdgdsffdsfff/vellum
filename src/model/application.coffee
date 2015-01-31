db = require '../utils/db'
_ = require 'lodash'
md5 = require 'MD5'
q = require 'q'

class Application
  createsyssqltpl: "CREATE TABLE `sysaction_##id` (`id` int(11) unsigned NOT NULL AUTO_INCREMENT, `appid` varchar(255) NOT NULL DEFAULT '' COMMENT '应用ID', `createtime` int(10) NOT NULL COMMENT '创建时间', `content` text NOT NULL COMMENT '日志内容', `level` tinyint(1) NOT NULL COMMENT '日志级别', PRIMARY KEY (`id`) ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='系统日志表';"

  createusersqltpl: "CREATE TABLE `useraction_##id` (`id` int(11) unsigned NOT NULL AUTO_INCREMENT, `appid` varchar(255) NOT NULL DEFAULT '' COMMENT '应用ID', `type` varchar(255) NOT NULL DEFAULT '' COMMENT '操作类型', `createtime` int(10) NOT NULL COMMENT '创建时间', `operator` int(11) NOT NULL COMMENT '操作人', `content` text NOT NULL COMMENT '日志内容', `level` tinyint(1) NOT NULL COMMENT '日志级别', PRIMARY KEY (`id`) ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='用户日志表';"

  checkAuthcode: (appid, authcode) ->
    deferred = q.defer()

    sql = 'select * from application where appid = :appid and authcode = :authcode'

    params =
      appid: appid
      authcode: authcode

    db.query sql, params, (err, rows) ->
      if not err
        if not _.isEmpty rows
          deferred.resolve rows
      deferred.reject err
      return
    return deferred.promise

  get: (appid) ->
    deferred = q.defer()

    sql = 'select * from application where appid = :appid limit 1'

    params =
      appid: appid

    db.query sql, params, (err, rows) ->
      if not err
        deferred.resolve rows
      deferred.reject err
      return
    return deferred.promise

  getList: () ->
    deferred = q.defer()
    sql = 'select * from application'
    db.query sql, (err, rows) ->
      if not err
        deferred.resolve rows
      deferred.reject err
      return

    return deferred.promise

  add: (name) ->
    deferred = q.defer()

    moment = require 'moment'
    appid = String moment().format 'X'
    authcode = (md5 appid + Math.random() * 1000).substr 0,16

    params =
      name: name
      appid: appid
      authcode: authcode

    sql = "insert into application (appid,name,authcode) values (:appid,:name,:authcode)"
    that = this

    db.query sql, params, (err, rows) ->
      if not err
        db.query that.createsyssqltpl.replace '##id', appid
        db.query that.createusersqltpl.replace '##id', appid
        deferred.resolve rows
      deferred.reject err
      return

    return deferred.promise

  getAction: (appid) ->
    deferred = q.defer()

    sql = 'select * from actiontype where appid = :appid'

    params =
      appid: appid

    db.query sql, params, (err, rows) ->
      if not err
        deferred.resolve rows
      deferred.reject err
      return
    return deferred.promise

  addAction: (appid, name, callname) ->
    deferred = q.defer()

    sql = 'insert into actiontype (appid,name,callname) values (:appid,:name,:callname)'

    params =
      name: name
      appid: appid
      callname: callname

    db.query sql, params, (err, rows) ->
      if not err
        deferred.resolve rows
      deferred.reject err
      return

    return deferred.promise

  delAction: (id) ->
    deferred = q.defer()

    sql = 'delete from actiontype where id = :id'

    params =
      id: id

    db.query sql, params, (err, rows) ->
      if not err
        deferred.resolve rows
      deferred.reject err
      return

    return deferred.promise

module.exports = new Application
