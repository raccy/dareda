import {app, BrowserWindow, ipcMain} from 'electron'

import path from 'path'
import url from 'url'
import fs from 'fs'

import yaml from 'js-yaml'

import LdapSearcher from './main/ldap_searcher'

fs.readFile path.join(__dirname, '..', 'dareda.yml'), (err, data) ->
  config = yaml.safeLoad(data)
  ldapSearcher = new LdapSearcher({
    url: config.ldap.url
    userBase: config.ldap.user_base
    groupBase: config.ldap.group_base
  })

mainWindow = null

createWindow = ->
  mainWindow = new BrowserWindow(width: 800, height: 600)
  mainWindow.loadURL(url.format(
    pathname: path.join(__dirname, 'index.html')
    protocol: 'file:'
    slashes: true
  ))
  # mainWindow.webContents.openDevTools()

  mainWindow.on 'closed', ->
    app.quit()

  ipcMain.on 'display-user', (event, dn) ->
    userWindow = new BrowserWindow(width: 800, height: 600, parent: mainWindow)
    userWindow.loadURL(url.format(
      pathname: path.join(__dirname, 'user.html')
      protocol: 'file:'
      search: dn
      slashes: true
    ))
    # userWindow.webContents.openDevTools()

app.on 'ready', createWindow

app.on 'window-all-closed', ->
  if process.platform != 'darwin'
    app.quit()

app.on 'activate', ->
  unless mainWindow?
    createWindow()
