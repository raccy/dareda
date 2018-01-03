import {h, app} from 'hyperapp'
import {ipcRenderer} from 'electron'
import login, {Login} from './renderer/login'

state = {
  login.state...
  filterText: ''
  filterList: []
  searchResult: []
}

filterNormalize = (filterList) ->
  attributeList = []
  (filter for filter in filterList when filter.value).filter (filter) ->
    if not attributeList.includes(filter.attribute)
      attributeList.push(filter.attribute)
      true
    else
      false

actions = {
  login.actions...


  updateFilterList: (filterList) -> (state) -> {filterList: filterList}
  updateFilterText: (filterText) -> (state) -> {filterText: filterText}
  updateSearchResults: (searchResult) -> (state) -> {searchResult: searchResult}
  setFilter: (attribute, value) -> (state, actions) ->
    filterList = filterNormalize([
      (filter for filter in state.filterList \
          when filter.attribute isnt attribute)...
      {attribute: attribute, value: value}
    ])
    await actions.updateFilterList(filterListSetted)
    actions.search()
    return
  search: -> (state, actions) ->
    ipcRenderer.send 'filter-list', state.filterList
  onFilterText: -> (state, actions) ->
    ipcRenderer.on 'filter-text', (event, arg) ->
      actions.updateFilterText(arg)
  onSearchResult: -> (state, actions) ->
    ipcRenderer.on 'search-result', (event, arg) ->
      actions.updateSearchResults(arg)
}

view = (state, actions) ->
  mainElement = if state.loginStatus is 'done'
    <Search />
  else
    <Login error={state.loginError} status={state.loginStatus}
      login={actions.login}  watchLogin={actions.watchLogin} />

  <main>
    {mainElement}
  </main>

app(state, actions, view, document.body)
