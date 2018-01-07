import {h} from 'hyperapp'
import {ipcRenderer} from 'electron'

export state = {
  searchFilter: ''
  searchEntries: []
  searchError: undefined
}

export actions = {
  updateSearch: ({filter, entries, error}) -> (state) ->
    {
      searchFilter: filter
      searchEntries: entries
      searchError: error
    }

  updateSearchResults: (searchResults) -> (state) ->
    {searchResults: searchResults}

  search: (filterList) -> (state, actions) ->
    console.log filterList
    ipcRenderer.send 'search', filterList: filterList
    return

  displayUser: (dn) -> (state) ->
    ipcRenderer.send 'display-user', dn
    return

  watchSearch: -> (state, actions) ->
    console.log 'watch search'
    ipcRenderer.on 'search-result', (event, arg) ->
      console.log arg
      actions.updateSearch(arg)
    return
}

MATCHINGS = [
  {id: 'exact', name: '完全一致', selected: false}
  {id: 'forward', name: '前方一致', selected: true}
  {id: 'partial', name: '部分一致', selected: false}
  {id: 'backward', name: '後方一致', selected: false}
  {id: 'approximate', name: '曖昧検索', selected: false}
]

ATTRIBUTES = [
  {id: 'uid', attr: 'uid', name: 'ユーザー名'}
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
  unless value
    search([])
    return
  matching = form.matching.value
  targets = (checkbox.value for checkbox in form.targets when checkbox.checked)
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
            praceholder="ユーザー名 or 名前" onkeyup={onchangeChild}
            oncreate={(element) -> element.focus()} />
        </div>
      </div>
      <div class="form-group">
        <div class="col-3">
          <label class="form-label" for="search-matching">検索方式</label>
        </div>
        <div class="col-9">
          <select id="search-matching" class="form-select" name="matching"
            onchange={onchangeChild}>
            {
              for matching in MATCHINGS
                <option key={matching.id} value={matching.id}
                  selected={matching.selected}>
                  {matching.name}
                </option>
            }
          </select>
        </div>
      </div>
      <div class="form-group">
        <div class="col-3">
          <label class="form-label">検索対象</label>
        </div>
        <div class="col-9">
          {
            for attribute in ATTRIBUTES
              <label key={attribute.id} class="form-checkbox">
                <input id={"search-targets-#{attribute.id}"} type="checkbox"
                  name="targets" value={attribute.attr} checked
                  onchange={onchangeChild} />
                  <i class="form-icon"></i>
                  {attribute.name}
              </label>
          }
        </div>
      </div>
    </fieldset>
  </form>

Entry = ({key, entry, displayUser}) ->
  <tr key={key} onclick={(event) -> displayUser(entry.dn)}>
    {
      for attribute in ATTRIBUTES
        <td key={attribute.id}>
          {entry[attribute.attr]}
        </td>
    }
  </tr>

EntryTable = ({entries, displayUser}) ->
  <table>
    <thead>
      <tr>
        {
          for attribute in ATTRIBUTES
            <th key={attribute.id}>
              {attribute.name}
            </th>
        }
      </tr>
    </thead>
    <tbody>
      {
        for entry in entries
          <Entry key={entry.uid} entry={entry} displayUser={displayUser} />
      }
    </tbody>
  </table>

export Search = ({filter, entries, error, search, displayUser, watchSearch}) ->
  <div key="search" id="search" oncreate={->
    console.log 'search created'
    watchSearch()
  }>
    <SearchInput search={search}/>
    <p>{filter or error}</p>
    <EntryTable entries={entries} displayUser={displayUser} />
  </div>

export default {
  state: state
  actions: actions
  Search: Search
}
