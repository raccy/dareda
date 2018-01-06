import {h} from 'hyperapp'

export state = {
  filterText: ''
  searchResults: []
}

export actions = {
  updateFilterText: (filterText) -> (state) ->
    {filterText: filterText}

  updateSearchResults: (searchResults) -> (state) ->
    {searchResults: searchResults}

  search: (filterList) -> (state, actions) ->
    ipcRenderer.send 'filter-list', filterList
    return

  displayUser: (dn) -> (state) ->
    ipcRenderer.send 'display-user', dn
    return

  watchResult: -> (state, actions) ->
    ipcRenderer.on 'search-result', (event, arg) ->
      actions.updateFilterText(arg.filterText)
      actions.updateSearchResults(arg.searchResults)
    return
}

TARGETS = [
  {id: 'uid', attr: 'uid', name: 'アカウント名'}
  {id: 'displayNam', attr: 'displayName', name: '名前(英字)'}
  {id: 'displayName_ja', attr: 'displayName;lang-ja', name: '名前(漢字)'}
  {id: 'displayName_lang_ja_phonetic', attr: 'displayName;lang-ja;phonetic', \
    name: '名前(ふりがな)'}
]

getParentForm = (node) ->
  if not node?
    return null
  if node.tagName.downCase() == 'form'
    return node
  getParentForm(node.parentElement)

parrentFormSubmit = (event) ->
  getParentForm(event.targe)?.submit()

SearchInput = ({search}) ->
  <form onsubmit={(event) ->
    event.preventDefault()
    form = event.target
    value = form.string.value
    matching = form.matching.value
    targets = (checkbox.value for checkbox in form.target when checkbox.checked)
    filterList = for target in targets
      {
        attr: target
        matching: matching
        value: value
      }
    search(filterList)
  }>
    <fieldset>
      <label for="search-string">検索文字列</label>
      <input id="search-string" type="text" name="string"
         praceholder="アカウント名 or 名前" onchange={parrentFormSubmit} />
      <label for="search-matching">一致形式</label>
      <select id="search-matching" name="matching" onchange={parrentFormSubmit}>
        <option value="exact">完全</option>
        <option value="forward">前方</option>
        <option value="partial">部分</option>
        <option value="backward">後方</option>
      </select>
      <label>検索対象</label>
      {
        for target in TARGETS
          <span key={target.attr}>
            <input id={"search-target-#{target.id}"} type="checkbox"
              name="target" onchange={parrentFormSubmit}
              value={target.attr} checked />
            <label for={"search-target-#{target.id}"}>
              {"#{target.name}(#{target.uid})"}
            </label>
          </span>
      }
    </fieldset>
  </form>

ResultItem = ({key, result, displayUser}) ->
  <tr key={key} onclick={-> displayUser(result.dn)}>
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
            displayUser={displayUser} />
      }
    </tbody>
  </table>

export Search = ({filterText, results, search, displayUser, watchResult}) ->
  <div id="search" oncreate={watchResult}>
    <SearchInput search={search}/>
    <p>{filterText}</p>
    <Results results={results} displayUser={displayUser} />
  </div>

export default {
  state: state
  actions: actions
  Search: Search
}
