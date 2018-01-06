import {h} from 'hyperapp'

filterNormalize = (filterList) ->
  attributeList = []
  (filter for filter in filterList when filter.value).filter (filter) ->
    if not attributeList.includes(filter.attribute)
      attributeList.push(filter.attribute)
      true
    else
      false

export state = {
  filterText: ''
  filterList: []
  searchResult: []
}

export actions = {
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
  displayUser: (userDn) -> (state) ->
    ipcRenderer.send ''

  onFilterText: -> (state, actions) ->
    ipcRenderer.on 'filter-text', (event, arg) ->
      actions.updateFilterText(arg)
  onSearchResult: -> (state, actions) ->
    ipcRenderer.on 'search-result', (event, arg) ->
      actions.updateSearchResults(arg)

}


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

SerchInput = () ->

ResultItem = ({result, displayUser}) ->
  <tr onclick={-> displayUser(result.dn)}>
    <td>{result.uid}</td>
    <td>{result.name}</td>
  </tr>

Results = ({results, displayUser}) ->

  <table>
    <thead>
      <tr>
        <th>アカウント</th>
        <th>名前</th>
      </tr>
    </thead>
    <tbody>
      {
        for result in results
          <ResultItem key={relust.uid} result={result}
              displayUser={displayUser}/>
      }
    </tbody>
  </table>




export Search = ({filterText, results, search, displayUser}) ->
  <div id="search">
    <SeachInput search={search}/>
    <p>{filterText}</p>
    <Result results={results} displayUser={displayUser} />
  </div>

export default {
  state: state
  actions: actions
  Search: Search
}
