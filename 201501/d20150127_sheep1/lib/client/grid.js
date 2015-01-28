var _ = require('lodash')

module.exports = function(socket, state_callback) {
	this.grid = {}

	this.toggleGrid = function(location, color) {
		if (location in grid) {
			delete grid[location]
			socket.emit('delete', { 'location': location })
			state_callback(null, location)
		} else {
			grid[location] = color
			socket.emit('setColor', { 'location': location, 'color': color })
			state_callback(color, location)
		}
	}

	this.setColor = function(location, color) {
		grid[location] = color
		state_callback(color, location)
	}

	this.clearCell = function(location) {
		if (location in grid) {
			delete grid[location]
		}
		state_callback(null, location)
	}

	this.isSet = function(location) {
		return location in grid
	}

	return this
}