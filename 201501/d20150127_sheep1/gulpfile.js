var gulp = require('gulp')
var browserify = require('browserify')
var source = require('vinyl-source-stream')

gulp.task('default', ['browserify'], function() {
	gulp.src(['./lib/index.html'])
	    .pipe(gulp.dest('./build'))
})

gulp.task('browserify', function() {
	return browserify('./lib/client.js')
	    .bundle()
	    .pipe(source('bundle.js'))
	    .pipe(gulp.dest('./build'))
})