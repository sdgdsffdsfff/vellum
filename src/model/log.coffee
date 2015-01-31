db = require '../utils/db'
_ = require 'lodash'
md5 = require 'MD5'
q = require 'q'
moment = require 'moment'

class Log
  loglevel:
    1: 'debug'
    2: 'info'
    3: 'warning'
    4: 'error'
    5: 'fatal'

  getCount: (appid, sqlwhere, type = 'user') ->
    deferred = q.defer()
    sql = "select count(id) as count from #{type}action_#{appid}#{sqlwhere}"

    db.query sql, (err, rows) ->
      if !err
        deferred.resolve rows[0]['count']
      deferred.reject err
      return
    return deferred.promise

  getData: (appid, sqlwhere, start = 0, pagesize = 10, type ='user') ->
    deferred = q.defer()
    sql = "select * from #{type}action_#{appid}#{sqlwhere} order by id desc limit #{start} , #{pagesize}"
    db.query sql, (err, rows) ->
      if !err
        _.forEach rows, (v, k) ->
          v['createtime'] = moment.unix(v['createtime']).format 'YYYY-MM-DD HH:mm:ss'
          return
        deferred.resolve rows
      deferred.reject err
      return
    return deferred.promise

  addUserLog: (appid, type, operator, content, level) ->
    deferred = q.defer()
    params =
      appid: appid
      type: type || ''
      createtime: moment().format 'X'
      operator: operator || 0
      content: content || ''
      level: level

    sql = "insert into useraction_#{appid}  (appid,type,createtime,operator,content,level) values (:appid,:type,:createtime,:operator,:content,:level)"

    db.query sql, params, (err, rows) ->
      if !err
        deferred.resolve rows
      deferred.reject err
      return

    return deferred.promise

  addSysLog: (appid, content, level) ->
    deferred = q.defer()
    params =
      appid: appid
      createtime: moment().format 'X'
      content: content || ''
      level: level
    sql = "insert into sysaction_#{appid} (appid,createtime,content,level) values (:appid,:createtime,:content,:level)"
    db.query sql, params, (err, rows) ->
      if !err
        deferred.resolve rows
      deferred.reject err
      return

    return deferred.promise

module.exports = new Log
