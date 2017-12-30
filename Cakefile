fs = require 'fs'
path = require 'path'
util = require 'util'
childProcess = require 'child_process'

exec = util.promisify(childProcess.exec)
mkdir = util.promisify(fs.mkdir)
stat = util.promisify(fs.stat)

srcDir = 'src'
dstDir = 'app'

mkdirIfNotExists = (path) ->
  try
    stats = await stat(path)
  catch
    await mkdir(path)
    stats = await stat(path)
  stats?.isDirectory()

task 'build:html', 'build html', (options) ->
  mkdirIfNotExists(dstDir)
  {stdout, stderr} = await exec("yarn run pug -o #{dstDir} #{srcDir}")
  console.log(stdout) if stdout?
  console.warn(stderr) if stderr?

task 'build:css', 'build css', (options) ->
  mkdirIfNotExists(dstDir)
  {stdout, stderr} = await exec("yarn run node-sass -o #{dstDir} -r #{srcDir}")
  console.log(stdout) if stdout?
  console.warn(stderr) if stderr?

task 'build:js', 'build js', (options) ->
  mkdirIfNotExists(dstDir)
  {stdout, stderr} = await exec(
    "yarn run coffee -b -c -t -o #{dstDir} #{srcDir}")
  console.log(stdout) if stdout?
  console.warn(stderr) if stderr?

task 'build', 'build all', (options) ->
  await invoke 'build:html'
  await invoke 'build:css'
  await invoke 'build:js'
