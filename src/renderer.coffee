import { h, app } from 'hyperapp'
import { ipcRenderer } from 'electron'

state =
  filterText: ''
  filterList: []
  searchResult: []

filterNormalize = (filterList) ->
  attributeList = []
  (filter for filter in filterList when filter.value).filter (filter) ->
    if not attributeList.includes(filter.attribute)
      attributeList.push(filter.attribute)
      true
    else
      false

actions =
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

searchTypes = [
  {
    id: 'uid'
    name: 'アカウント名'
    atrribute: 'uid'
    type: 'text'
    pattern: /[\w-]+/
    praceholder: 'username...'
  }
]

Input = ({id, name, attribute, type, pattern, praceholder, updateFilter}) ->
  <div>
    <label>{"#{name}(#{attribute})"}</label>
    <input
      key={id}
      type={type}
      pattern={pattern}
      praceholder={placeholder}
      onchange={({target:{value}}) ->
        updateFilter(attribute, value)
      }
    />
  </div>



view = (state, actions) ->
  <main>
    <label>名前(ja)</label>
    <input
      type="text"
    />
  </main>

app(state, actions, view, document.body)
