import {ipcMain} from 'electron'
import ldap from 'ldapjs'

export default class LdapSearcher
  constructor: ({@url, @userBase, @groupBase}) ->
    @client = ldap.createClient(url: @url)
    ipcMain.on 'login', @login
    ipcMain.on 'search', @search
    ipcMain.on 'user', @user

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

  search: (event, {filterList}) =>
    filter = @createFilter(filterList)
    defaultResult = {
      filter: filter?.toString() or ''
      entries: []
      error: undefined
    }
    unless filter?
      # no search
      event.sender.send 'search-result', defaultResult
      return

    attributes = ['uid', 'displayName', 'displayName;lang-ja',
      'displayName;lang-ja;phonetic']
    options =
      filter: filter
      scope: 'one'
      attributes: attributes
      sizeLimit: 10
    @client.bind @dn, @password, (err) =>
      if err instanceof ldap.LDAPError
        event.sender.send 'search-result', {
          defaultResult...
          error: err.message()
        }
        return
      entries = []
      @client.search @userBase, options, (err, res) ->
        if err instanceof ldap.LDAPError
          event.sender.send 'search-result', {
            defaultResult...
            error: err.message()
          }
          return
        error = undefined
        res.on 'searchEntry', (entry) ->
          entryObj = {dn: entry.objectName}
          for attr in entry.attributes
            if attributes.includes(attr.type)
              entryObj[attr.type] = attr.vals
          entries.push(entryObj)
        res.on 'error', (err) ->
          error = err
        res.on 'end', (result) ->
          event.sender.send 'search-result', {
            defaultResult...
            entries: entries
            error: err
          }

  user: (event, {dn}) =>
    options = scope: 'base', sizeLimit: 1
    @client.bind @dn, @password, (err) =>
      if err instanceof ldap.LDAPError
        event.sender.send 'user-result', {
          defaultResult...
          error: err.message()
        }
        return
      entries = []
      @client.search dn, options, (err, res) ->
        if err instanceof ldap.LDAPError
          event.sender.send 'user-result', {
            defaultResult...
            error: err.message()
          }
          return
        error = undefined
        res.on 'searchEntry', (entry) ->
          entryObj = {dn: entry.objectName}
          for attr in entry.attributes
            entryObj[attr.type] = attr.vals
          entries.push(entryObj)
        res.on 'error', (err) ->
          error = err
        res.on 'end', (result) ->
          if entries.length > 0
            event.sender.send 'user-result', {
              defaultResult...
              user: entries[0]
              error: err
            }
          else
            event.sender.send 'user-result', {
              defaultResult...
              error: 'not found'
            }

  createFilter: (filterList) ->
    list = for filter in filterList
      switch filter.matching
        when 'exact'
          new ldap.EqualityFilter(
            attribute: filter.attr
            value: filter.value
          )
        when 'forward'
          new ldap.SubstringFilter(
            attribute: filter.attr
            initial: filter.value
          )
        when 'partial'
          new ldap.SubstringFilter(
            attribute: filter.attr
            any: [filter.value]
          )
        when 'backward'
          new ldap.SubstringFilter(
            attribute: filter.attr
            final: filter.value
          )
        when 'approximate'
          new ldap.ApproximateFilter(
            attribute: filter.attr
            value: filter.value
          )
        else
          null
    list = (filter for filter in list when filter?)

    if list.length == 0
      return

    if list.length == 1
      list[0]
    else
      new ldap.OrFilter(filters: list)

  ldapLogin: ->
    new Promise((resolve, reject) =>
      @client.bind @dn, @password, (err) =>
        if err instanceof ldap.LDAPError
          reject(err)
        else
          resolve(@dn)
    )

  getUserDn: (username) ->
    "uid=#{username},#{@userBase}"
