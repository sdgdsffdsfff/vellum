express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
session = require 'express-session'

app = express()

app.engine '.html', require('ejs').__express
app.set 'view engine', 'html'
app.set 'views', path.join __dirname, '/views/'

app.use logger 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true
app.use cookieParser()
app.use session secret: 'vellum', resave: false, saveUninitialized: false
app.use express.static path.join __dirname, '../public'

app.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
  res.header 'Access-Control-Allow-Methods', 'PUT,POST,GET,DELETE,OPTIONS'
  res.header 'X-Powered-By', 'express 4.2.1'
  next()
  return

routes = require './routes'
routes app

app.use (req, res, next) ->
  err = new Error 'Not Found'
  err.status = 404
  next err
  return

app.set 'port', 3000

server = app.listen app.get('port'), ->
  console.log 'vellum is running listening on port'+app.get 'port'
  return
