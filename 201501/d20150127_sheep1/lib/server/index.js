var fs = require('fs')

function handler(req, res) {
	var url = req.url
	if (req.url == '/') {
		url = '/index.html'
	}
	var path = __dirname + '/../client' + url
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

var app = require('http').createServer(handler)
var io = require('socket.io')(app)
var grid = require('./grid')
var board = new grid(20)
app.listen(8000)
console.log('Listening on 8000')

board.on('set', function(location, color) {
	io.emit('setColor', location, color)
})

board.on('clear', function(location) {
	io.emit('delete', location)
})

io.on('connection', function (socket) {
	console.log(board.grid)
	socket.emit('state', board.grid)

	socket.on('clicked', function (data) {
		if (!board.matches(data.location, data.color)) {
			board.setColor(data.location, data.color)
		} else {
			board.clearCell(data.location)
		}
	})
})
