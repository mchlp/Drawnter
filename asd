/*global $*/
/*global io*/

var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");

var width = canvas.width;
var height = canvas.height;

var drawableWidth = canvas.width;
var drawableHeight = canvas.height;

var prevCoord = null;
var leftButtonDown = false;
var leftMouseDownInDrawableCanvas = false;
var mouseInDrawableCanvas = false;
var canvasEditable = true;
var lineStarted = false;
var mousePos = new coord(0, 0);

var brushRadius = 5;
var color = getRandomColor();

/*
var inkLeft = 10000;
var inkLeftPos = [10, 10];
var finalData = [];

var canvasDataSent = false; // RESET THIS WHEN DONE
var canvasDataSent2 = false;

var submitButtonStatus = "not submitted"; // RESET THIS WHEN DONE
var finalVote = -1;
*/

var socket = io();

ctx.font = '30px Arial';

function rgb(r, g, b) {
    this.r = r;
    this.g = g;
    this.b = b;
}

function coord(x, y) {
    this.x = x;
    this.y = y;
    this.print = function() {
        console.log("x: " + x + " y: " + y);
    }
}

function getMouseCoordInCanvas(canvas) {
    var rect = canvas.getBoundingClientRect();
    return new coord(mousePos.x - rect.left, mousePos.y - rect.top);
}

//function to draw lines
function draw(curCoord, color) {
    ctx.beginPath();
    ctx.fillStyle = color;
    ctx.arc(curCoord.x, curCoord.y, brushRadius, 0, Math.PI * 2, true);
    //ctx.closePath();
    ctx.fill();
    socket.emit('circle', { x: curCoord.x, y: curCoord.y, color: color});
}

function draw2(curCoord, color) {
    ctx.beginPath();
    ctx.fillStyle = color; //red
    ctx.arc(curCoord.x, curCoord.y, brushRadius, 0, Math.PI * 2, true);
    //ctx.closePath();
    ctx.fill();
}

//listeners for moues button changes when mouse is in canvas
$("canvas").mousedown(function() {
    leftButtonDown = true;
    if (getMouseCoordInCanvas(canvas).y < drawableHeight && getMouseCoordInCanvas(canvas).x < drawableWidth) {
        leftMouseDownInDrawableCanvas = true;
    }
})

$("canvas").mouseup(function() {
    leftButtonDown = false;
    leftMouseDownInDrawableCanvas = false;
    lineStarted = false;
})

$("canvas").mouseleave(function() {
    leftMouseDownInDrawableCanvas = false;
    lineStarted = false;
})

//track mouse position
$(document).mousemove(function(e) {
    mousePos = new coord(e.pageX, e.pageY);
    if (getMouseCoordInCanvas(canvas).y < drawableHeight && getMouseCoordInCanvas(canvas).x < drawableWidth) {
        mouseInDrawableCanvas = true;
    }
    else {
        mouseInDrawableCanvas = false;
        leftMouseDownInDrawableCanvas = false;
    }
})

function inside(pos, rect) {
    //.log(pos.x, pos.y, rect.x, rect.x + rect.width, rect.y, rect.y + rect.height);
    return pos.x > rect.x && pos.x < rect.x + rect.width && pos.y < rect.y + rect.height && pos.y > rect.y;
}

function getRandomColor() {
  var letters = '0123456789ABCDEF';
  var color = '#';
  for (var i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
}

// Buttons
var joinBtn = {
    x: (width * 0.5 - 100),
    y: height * 0.5,
    width: 200,
    height: 100
};

/*
var submitBtn = {
    x: drawableWidth,
    y: height - (width - drawableWidth) / 2,
    width: width - drawableWidth,
    height: (width - drawableWidth) / 2,
}
*/
var phase0Init = false;

var getForm = function() {
    var id = document.getElementById('roomID').value;
    console.log(id);
}

var image = new Image();
image.src = "/res/submit_Before.png";

socket.on('update', function(data) {
    ctx.fillStyle = "#000000";
    if (data.state == -1) {
        /*
        ctx.clearRect(0, 0, width, height);
        ctx.textAlign = "center";
        ctx.fillText("Menu state", width * 0.5, 100);
        ctx.fillStyle = "#FF0000";
        ctx.fillRect(joinBtn.x, joinBtn.y, joinBtn.width, joinBtn.height);
        ctx.fillStyle = "#000000";
        ctx.fillText("Play", joinBtn.x + (joinBtn.width / 2), joinBtn.y + (joinBtn.height / 2));
        */
        ctx.drawImage(image, joinBtn.x, joinBtn.y);

        if (leftMouseDownInDrawableCanvas && inside(getMouseCoordInCanvas(canvas), joinBtn)) {
            console.log("HELLO");
            socket.emit('joinBtn', {});
            ctx.clearRect(0, 0, width, height);
        }
    }
    else if (data.state == 0) {
        if(phase0Init == false) {
            ctx.clearRect(0, 0, width, height);
            phase0Init = true;
            socket.emit("preDrawNow", {});
        }
        //game loop
        //ctx.textAlign = "center";
        //ctx.fillText("Draw the template", width * 0.5, 100);
        /*
        //fill side bar
        ctx.fillStyle = "#7fb0ff";
        ctx.textAlign = "right"
        ctx.fillRect(drawableWidth, 0, width - drawableWidth, height);
         */
         
        if (leftMouseDownInDrawableCanvas) {
            draw(getMouseCoordInCanvas(canvas), color);
        }
       
    }
});

socket.on('drawCircle', function(data) {
    if(phase0Init)
        draw2(new coord(data.x, data.y), data.color);
})

socket.on('preDraw', function(data) {
    console.log("PRE DRAWING CLIENT SIDE")
    console.log(data)
    for(var i = 0; i < data.circles.length; i++) {
        draw2(new coord(data.circles[i].x, data.circles[i].y), data.circles[i].colour);
        console.log(1);
    }
});
