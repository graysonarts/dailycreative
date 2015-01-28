var app = require('http').createServer(handler)
var io = require('socket.io')(app)
var fs = require('fs')
var grid = require('./client/grid')
var board = grid(io, function() {})
app.listen(8000);

function handler(req, res) {
	var url = req.url
	if (req.url == '/') {
		url = '/index.html'
	}
	var path = __dirname + "/../build" + url
	fs.readFile(path,
		function (err, data) {
			if (err) {
				console.log(path, err)
				res.writeHead(500)
				return res.end('Error Loading index.html')
			}

			res.writeHead(200)
			res.end(data)
		})
}

io.on('connection', function (socket) {
	console.log(board.grid)
	socket.emit('state', board.grid)

	socket.on('clicked', function (data) {
		board.toggleGrid(data.location, data.color)
	})
})