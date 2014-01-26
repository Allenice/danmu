
/**
 * Module dependencies.
 */

var http = require('http');
var path = require('path');
var express = require('express');
var routes = require('./routes');

var sockets = require('./modules/sockets');
var mongoDb = require('./modules/db');
var global = require('./global');

global.resumable.uploadDir = path.join(__dirname, '/uploads')

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'twig');
app.use(express.favicon());
app.use(express.logger('dev'));

app.use(express.bodyParser({
    keepExtensions: true,
    uploadDir: './temp'
}));

app.use(express.methodOverride());
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'public/lib/')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

routes(app);

var server = http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});

var io = require('socket.io').listen(server);
sockets(io);