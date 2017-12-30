fs = require 'fs'
path = require 'path'
util = require 'util'
childProcess = require 'child_process'

exec = util.promisify(childProcess.exec)
mkdir = util.promisify(fs.mkdir)
stat = util.promisify(fs.stat)
copyFile = util.promisify ({src, dest}, callback) ->
  fs.copyFile(src, dest, callback)

srcDir = 'src'
dstDir = 'app'

mkdirIfNotExists = (path) ->
  try
    stats = await stat(path)
  catch
    await mkdir(path)
    stats = await stat(path)
  unless stats?.isDirectory()
    throw new Error("faild to make direcoty #{path}")

task 'build:html', 'build html', (options) ->
  await mkdirIfNotExists(dstDir)
  {stdout, stderr} = await exec("yarn run pug -o #{dstDir} #{srcDir}")
  console.log(stdout) if stdout?
  console.warn(stderr) if stderr?

task 'build:css', 'build css', (options) ->
  await mkdirIfNotExists(dstDir)
  {stdout, stderr} = await exec("yarn run node-sass -o #{dstDir} -r #{srcDir}")
  console.log(stdout) if stdout?
  console.warn(stderr) if stderr?

task 'build:js', 'build js', (options) ->
  await mkdirIfNotExists(dstDir)
  {stdout, stderr} = await exec(
    "yarn run coffee -b -c -t -o #{dstDir} #{srcDir}")
  console.log(stdout) if stdout?
  console.warn(stderr) if stderr?

task 'build:package', 'build package', (options) ->
  await mkdirIfNotExists(dstDir)
  await copyFile src: 'package.json', dest: path.join(dstDir, 'package.json')
  {stdout, stderr} = await exec("cd #{dstDir} && yarn install --production")
  console.log(stdout) if stdout?
  console.warn(stderr) if stderr?

task 'build', 'build all', (options) ->
  await invoke 'build:html'
  await invoke 'build:css'
  await invoke 'build:js'
  await invoke 'build:package'
