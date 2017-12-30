fs = require 'fs'
path = require 'path'
util = require 'util'
childProcess = require 'child_process'
exec = util.promisify(childProcess.exec)
readdir = util.promisify(fs.readdir)
statPromise = util.promisify(stat)

srcDir = 'dst'
dstDir = 'app'
dirList =
  html: 'html'
  css: 'css'
  js: 'js'


isDirectoryPromise = (filePath) ->
  stats = await statPromise(filePath)
  stats.isDirectory()


task 'build:html', 'build html',
(option) ->
  pug = require 'pug'
  srcDirPath = path.join(srcDir, dirList.html)
  files = await readdir(srcDirPath)
  files.forEach (file) ->
    filePath = path.join(srcDirPath, file)
