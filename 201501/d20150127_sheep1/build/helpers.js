module.exports = {
    getBundleName: function () {
        var version = require('../package.json').version
        var name = require('../package.json').name

        return version + '.' + name + '.min'
    }
}
