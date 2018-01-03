import {ipcMain} from 'electron'
import ldap from 'ldapjs'

export default class LdapSearcher
  constructor: ({@url, @userBase, @groupBase}) ->
    @client = ldap.createClient(url: @url)
    ipcMain.on 'login', @login
    ipcMain.on 'search', @search
    ipcMain.on 'user', @user
    ipcMain.on 'groups', @groups

  login: (event, {@username, @password}) =>
    @dn = @getUserDn(@username)
    try
      await @ldapLogin()
      event.sender.send 'login-result', status: 'success'
    catch error
      switch
        when error instanceof ldap.InvalidCredentialsError
          event.sender.send 'login-result',
            status: 'failure'
            error: 'ユーザー名またはパスワードが違います。'
        else
          event.sender.send 'login-result',
           status: 'error'
           error: error.message

  search: (event, {filter}) =>
    @filter = @createFilter(filter)
    event.sender.send 'filter-text', @filter.toString()

    attributes = ['uid', 'displayName', 'displayName;lang-ja']
    options = filter: @filter, attributes: attributes, sizeLimit: 10
    @client.bind @dn, @password, (err) =>
      if err instanceof ldap.LDAPError
        event.sender.send 'search-result', {err: err.message()}
        return
      entries = []
      @client.search @userBase, options, (err, res) ->
        if err instanceof ldap.LDAPError
          event.sender.send 'search-result', {err: err.message()}
          return
        res.on 'searchEntry', (entry) ->
          entries.push(entry)
        res.on 'end', (result) ->
          console.log(entries)
          event.sender.send 'search-result', {entries: entries}

  user: (event, userDn) =>

  groups: (event, group) ->

  createFilter: (filterList) ->
    list = for filter in filterList
      switch filter.matchType
        when 'perfect'
          new ldap.EqualityFilter(
            attribute: filter.attr
            value: value
          )
        when 'forward'
          new ldap.SubstringFilter(
            attribute: filter.attr
            initial: filter.value
          )
        when 'pertial'
          new ldap.SubstringFilter(
            attribute: filter.attr
            any: [filter.value]
          )
    if list.length is 1
      list[0]
    else
      new ldap.AndFilter(filters: list)

  ldapLogin: ->
    console.log("login: #{@dn}")
    new Promise((resolve, reject) =>
      @client.bind @dn, @password, (err) =>
        if err instanceof ldap.LDAPError
          console.log("faild to login")
          reject(err)
        else
          console.log("succeeded to login")
          resolve(@dn)
    )

  getUserDn: (username) ->
    "uid=#{username},#{@userBase}"
