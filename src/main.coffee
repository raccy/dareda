import {app, BrowserWindow} from 'electron'

import path from 'path'
import url from 'url'

mainWindow = null

createWindow = ->
  mainWindow = new BrowserWindow(width: 800, height: 600)
  mainWindow.loadURL(url.format(
    pathname: path.join(__dirname, 'index.html')
    protocol: 'file:'
    slashes: true
  ))
  mainWindow.webContents.openDevTools()

  mainWindow.on 'closed', ->
    mainWindow = null

app.on 'ready', createWindow

app.on 'window-all-closed', ->
  if process.platform isnt 'darwin'
    app.quit()

app.on 'activate', ->
  unless mainWindow?
    createWindow()

console.log process.version
