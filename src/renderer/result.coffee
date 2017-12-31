import { h, app } from 'hyperapp'
import { ipcRenderer } from 'electron'

state =
  filterText: ''
  filterList: []
  searchResult: []

actions =
  close: -> ->
    ipcRenderer('colse-result', )
    return

view = (state, actions) ->
  <main>
    <label>名前(ja)</label>
    <input
      type="text"
    />
    <button onclick={actions.close}>
      閉じる
    </button>
  </main>

app(state, actions, view, document.body)
