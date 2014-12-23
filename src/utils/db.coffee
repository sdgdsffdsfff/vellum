mysql = require 'mysql'
config = require '../../config.json'
pool = mysql.createPool host:config.mysql.host, port:config.mysql.port, user:config.mysql.user, password: config.mysql.password, database: config.mysql.database

pool.config.connectionConfig.queryFormat = (query, values) ->
  return query if !values
  return query.replace /\:(\w+)/g, ((txt, key) ->
    if values.hasOwnProperty key
      return this.escape values[key]
    return txt
  ).bind(this)

module.exports = pool
