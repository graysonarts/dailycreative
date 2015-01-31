/* jshint browser: true */
/* global io */
(function() {
	var supports_html5_storage = function() {
       try {
         return 'localStorage' in window && window.localStorage !== null;
       } catch (e) {
         return false;
       }
    }

    var random_color = function() {
    	var r = Math.floor(Math.random() * 255)
    	var g = Math.floor(Math.random() * 255)
    	var b = Math.floor(Math.random() * 255)

    	return '#' + r.toString(16) + g.toString(16) + b.toString(16)
    }

	var grid_size = 20
	var grid = require('../shared/grid')
	var index_template = require('./templates/grid.jade')
    console.log(index_template)
	var _ = require('lodash')
	var color = random_color()

	// Store your random color so that it's always your random color
	if (supports_html5_storage()) {
		color = localStorage.color || color
		localStorage.color = color
	}

	document.body.innerHTML = index_template({
		rows: _.range(grid_size),
		cols: _.range(grid_size)
	})

	    var socket = io()
	    var board = new grid(20);
	    console.log(board)

	    board.on('set', function(location, color) {
	    	var element = document.getElementById(location)
	    	element.style.backgroundColor = color
	    })

	    board.on('clear', function(location) {
	    	var element = document.getElementById(location)
	    	element.style.backgroundColor = ''
	    })

	    socket.on('state', function(data) {
	    	var elements = document.getElementsByClassName('grid-cell')

	    	_.forEach(elements, function (element) {
	    		if (element.id in data) {
	    			board.setColor(element.id, data[element.id])
	    		} else {
	    			board.clearCell(element.id)
	    		}
	    	})
	    })

	    socket.on('delete', function(location) {
	    	board.clearCell(location)
	    })

	    socket.on('setColor', function(location, color) {
	    	board.setColor(location, color)
	    })

	    var elements = document.getElementsByClassName('grid-cell')

	    _.forEach(elements, function (n) {
	    	n.addEventListener('click', function() {
	    		console.log(n.id)
	    		socket.emit('clicked', {location: n.id, color: color})
	    	})
	    })
})()
