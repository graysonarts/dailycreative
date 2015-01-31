var gulp = require('gulp')
//var autoprefixer = require('gulp-autoprefixer')
var jade = require('gulp-jade')
//var sourcemaps = require('gulp-sourcemaps')
var browserify = require('browserify')
//var livereload = require('gulp-livereload')
var source = require('vinyl-source-stream')
var buffer = require('vinyl-buffer')
//var rename = require('gulp-rename')

var helpers = require('./build/helpers.js')


gulp.task('server-js', function () {
    return gulp.src(['lib/shared/*.js', 'lib/server/*.js'])
        .pipe(gulp.dest('dist/server'))
})

gulp.task('client-initial-view', function () {
    return gulp.src(['lib/client/templates/index.jade'])
        .pipe(jade({
            locals: {
                bundle: helpers.getBundleName() + '.js'
            }
        }))
        .pipe(gulp.dest('dist/client'))
})

gulp.task('css', function () {
    return gulp.src(['lib/client/assets/style.css'])
        .pipe(gulp.dest('dist/client/assets'))
})

gulp.task('client-js', function () {
    var bundler = browserify({
        entries: ['./lib/client/client.js']
    })

    var bundle = function () {
        return bundler
            .transform(require('jadeify'))
            .bundle()
            .pipe(source(helpers.getBundleName() + '.js'))
            .pipe(buffer())
            .pipe(gulp.dest('dist/client'))
    }

    return bundle()
})

gulp.task('default', ['server-js', 'client-js', 'client-initial-view', 'css'], function () {

})


//gulp.task('default', ['browserify'], function() {
//	gulp.src(['./lib/index.html'])
//	    .pipe(gulp.dest('./build'))
//})
//
//gulp.task('browserify', function() {
//	return browserify('./lib/client.js')
//	    .bundle()
//	    .pipe(source('bundle.js'))
//	    .pipe(gulp.dest('./build'))
//})

