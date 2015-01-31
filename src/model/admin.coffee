db = require '../utils/db'
_ = require 'lodash'
md5 = require 'MD5'
q = require 'q'

class Admin
  checkLogin: (username, password) ->
    deferred = q.defer()
    sql = 'select id from admin where username = :username and password = :password'
    params =
      username: username
      password: md5 password
    db.query sql, params, (err, rows) ->
      if not err
        if not _.isEmpty rows
          deferred.resolve rows
      deferred.reject err
      return

    return deferred.promise


module.exports = new Admin
