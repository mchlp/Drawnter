function coord(x, y) {
    this.x = x;
    this.y = y;
    this.print = function() {
        console.log("x: " + x + " y: " + y);
    }
}

function colorCoord(x, y, colour) {
    this.x = x;
    this.y = y;
    this.colour = colour;
}

var express = require('express');
var app = express();
var serv = require('http').Server(app);

app.get('/', function(req, res) {
    res.sendFile(__dirname + '/client/index.html');
});
app.get('/res/submit_Before.png', function(req, res) {
    res.sendFile(__dirname + '/res/submit_Before.png');
});
app.get('/res/Title.png', function(req, res) {
    res.sendFile(__dirname + '/res/Title.png');
});
app.get('/res/Eraser.png', function(req, res) {
    res.sendFile(__dirname + '/res/Eraser.png');
});
app.use('/client', express.static(__dirname + '/client'));
serv.listen(8080);
console.log("Server started.");

function room(id) {
    this.id = id;
    this.players = [];
    this.circles = [];
    this.add = function(id) {
        this.players.push(id);
    }
}

var rooms = {};
var circles = [];

var io = require('socket.io')(serv, {});

var SOCKET_LIST = {};
var FPS = 60;

var phase = 0;

io.sockets.on('connection', function(socket) {
    console.log('New Socket connection');
    // Generate ID
    var id = 0;
    var unique = false;
    while (!unique) {
        id = Math.random();
        unique = true;
        for (var i in SOCKET_LIST) {
            if (SOCKET_LIST[i].id == id) {
                unique = false;
                break;
            }
        }
    }
    socket.id = id;

    // Attributes
    socket.state = -1;
    //socket.circles = new Array();

    // Add socket
    SOCKET_LIST[socket.id] = socket;

    // When player disconnects
    socket.on('disconnect', function() {
        delete SOCKET_LIST[socket.id];
    });
    
    socket.on('createBtn', function(data) {
        var id = 0;
        var unique = false;
        while (!unique) {
            id = Math.random();
            unique = true;
            for (var i in SOCKET_LIST) {
                if (SOCKET_LIST[i].id == id) {
                    unique = false;
                    break;
                }
            }
        }
        rooms[id] = new room(id);
        rooms[id].add(socket.id);
        socket.state = 0;
    });
    
    socket.on('joinBtn', function(data) {
        socket.state = 0;
    });
    
    socket.on('preDrawNow', function(data) {
        console.log("CALLED PREDRAW NOW");
       socket.emit('preDraw', {circles: circles}); 
    });

    socket.on('circle', function(data) {
        circles.push(new colorCoord(data.x, data.y, data.color));
        //socket.circlesLength++;
        //socket.emit('circle', data);
        for (var i in SOCKET_LIST) {
            var socket = SOCKET_LIST[i];
            socket.emit('drawCircle', {
                x: data.x,  
                y: data.y,
                color: data.color
            });
        }
    });
});

// Main game loop
setInterval(function() {
    // Send data to client
    for (var i in SOCKET_LIST) {
        // Calculations
        var socket = SOCKET_LIST[i];
        //console.log(circles)
        socket.emit(
            'update', {
                state: socket.state
            });
    }
}, 1000 / FPS); // 25 FPS, keep it low for speed
