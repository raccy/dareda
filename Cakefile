fs = require 'fs'
path = require 'path'
util = require 'util'
child_process = require 'child_process'

exec = util.promisify(child_process.exec)
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
  {stdout, stderr} = await exec("yarn run pug \
      -o #{dstDir} #{srcDir}")
  console.log(stdout) if stdout?
  console.warn(stderr) if stderr?

task 'build:css', 'build css', (options) ->
  await mkdirIfNotExists(dstDir)
  {stdout, stderr} = await exec("yarn run node-sass \
      --importer node_modules/node-sass-package-importer/dist/cli.js \
      -o #{dstDir} -r #{srcDir}")
  console.log(stdout) if stdout?
  console.warn(stderr) if stderr?

task 'build:js', 'build js', (options) ->
  await mkdirIfNotExists(dstDir)
  {stdout, stderr} = await exec("yarn run coffee \
      -b -c -t \
      -o #{dstDir} #{srcDir}")
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

task 'watch:html', 'watch html', (options) ->
  cp = child_process.spawn "yarn run pug \
      -w \
      -o #{dstDir} #{srcDir}"
  , [], {shell: true}
  cp.stdout.on 'data', (data) ->
    console.log(String(data))
  cp.stderr.on 'data', (data) ->
    console.log(String(data))
  cp.on 'error', (error) ->
    console.error(String(error))
    throw error
  process.on 'SIGINT', ->
    cp.kill()

task 'watch:css', 'watch css', (options) ->
  cp = child_process.spawn "yarn run node-sass \
      -w \
      --importer node_modules/node-sass-package-importer/dist/cli.js \
      -o #{dstDir} -r #{srcDir}"
  , [], {shell: true}
  cp.stdout.on 'data', (data) ->
    console.log(String(data))
  cp.stderr.on 'data', (data) ->
    console.log(String(data))
  cp.on 'error', (error) ->
    console.error(String(error))
    throw error
  process.on 'SIGINT', ->
    cp.kill()

task 'watch:js', 'watch js', (options) ->
  cp = child_process.spawn "yarn run coffee \
      -m
      -w \
      -b -c -t \
      -o #{dstDir} #{srcDir}"
  , [], {shell: true}
  cp.stdout.on 'data', (data) ->
    console.log(String(data))
  cp.stderr.on 'data', (data) ->
    console.log(String(data))
  cp.on 'error', (error) ->
    console.error(String(error))
    throw error
  process.on 'SIGINT', ->
    cp.kill()

task 'watch', 'watch all', (options) ->
  invoke 'watch:html'
  invoke 'watch:css'
  invoke 'watch:js'

task 'run', 'run electron', (options) ->
  ps = child_process.spawn('yarn', ['run', 'electron', 'app'], {shell: true})
  ps.stdout.on 'data', (data) ->
    console.log(String(data))
  ps.stderr.on 'data', (data) ->
    console.warn(String(data))
  ps.on 'error', (error) ->
    console.error(String(error))
    throw error
