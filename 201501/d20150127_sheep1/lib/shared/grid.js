var util = require('util')
var EventEmitter = require('events').EventEmitter;
// var _ = require('lodash')

function Grid(size) {
	EventEmitter.call(this)

	this.grid = {}
	this.size = size

	return this
}

util.inherits(Grid, EventEmitter)

Grid.prototype.inBounds = function(location) {
	console.log('inBounds:' + location)
	if (location === undefined) {
		return false // undefined locations are always out of bounds
	}
	var pieces = location.split('-')
	var y = parseInt(pieces[1])
	var x = parseInt(pieces[2])

	var retval = x >= 0 && y >= 0 && y < this.size && x < this.size
	console.log(retval ? 'inbounds' : 'outbounds')
	return retval
}

Grid.prototype.matches = function(location, color) {
	return this.grid[location] == color
}

Grid.prototype.isSet = function(location) {
	return location in this.grid
}

Grid.prototype.setColor = function(location, color) {
	if (this.inBounds(location)) {
		console.log('setColor:' + location + '=>' + color)
		this.grid[location] = color
		this.emit('set', location, color)
	}
}

Grid.prototype.clearCell = function(location) {
	if (location in this.grid) {
		console.log('clearCell:' + location)
		delete this.grid[location]
		this.emit('clear', location)
	}
}
module.exports = Grid