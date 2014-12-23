gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
watch = require 'gulp-watch'
gulp.task 'default', ->
  gulp.src('src/views/*').pipe(gulp.dest 'build/views/')
  gulp.src('src/**/*.coffee').pipe(watch('src/**/*.coffee')).pipe(coffee({bare: true}).on('error', gutil.log)).pipe(gulp.dest 'build/')
  return

gulp.task 'build', ->
  gulp.src('src/views/*').pipe(gulp.dest 'build/views/')
  gulp.src('src/**/*.coffee').pipe(coffee({bare: true}).on('error', gutil.log)).pipe(gulp.dest 'build/')
  return
