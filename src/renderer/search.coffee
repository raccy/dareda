import {h} from 'hyperapp'
import {ipcRenderer} from 'electron'

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
    console.log filterList
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
  if node.tagName.toLowerCase() == 'form'
    return node
  getParentForm(node.parentElement)

searchSubmit = (form, search) ->
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

SearchInput = ({search}) ->
  onsubmit = (event) ->
    event.preventDefault()
    searchSubmit(event.target, search)
  onchangeChild = (event) ->
    searchSubmit(getParentForm(event.target), search)
  <form class="form-horizontal" onsubmit={onsubmit}>
    <fieldset>
      <div class="form-group">
        <div class="col-3">
          <label class="form-label" for="search-string">検索文字列</label>
        </div>
        <div class="col-9">
          <input id="search-string" class="form-input" type="text" name="string"
             praceholder="ユーザー名 or 名前" onkeyup={onchangeChild} />
        </div>
      </div>
      <div class="form-group">
        <div class="col-3">
          <label class="form-label" for="search-matching">一致形式</label>
        </div>
        <div class="col-9">
          <select id="search-matching" class="form-select" name="matching"
            onchange={onchangeChild}>
            <option value="exact">完全</option>
            <option value="forward" selected>前方</option>
            <option value="partial">部分</option>
            <option value="backward">後方</option>
          </select>
        </div>
      </div>
      <div class="form-group">
        <div class="col-3">
          <label class="form-label">検索対象</label>
        </div>
        <div class="col-9">
          {
            for target in TARGETS
              <label key={target.id} class="form-checkbox">
                <input id={"search-target-#{target.id}"} type="checkbox"
                  name="target" value={target.attr} checked
                  onchange={onchangeChild} />
                  <i class="form-icon"></i>
                  {target.name}
              </label>
          }
        </div>
      </div>
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
