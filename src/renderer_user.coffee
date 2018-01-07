import {h, app} from 'hyperapp'
import {ipcRenderer} from 'electron'

state = {
  dn: ''
  user: undefined
  error: undefined
}

actions = {
  updateUser: -> ({dn, user, error}) -> (state) ->
    {dn: dn, user: user, error: error}
  user: (dn) -> (state, actions) ->
    ipcRenderer.send 'user', dn: dn
  watchUser: -> (state, actions) ->
    ipcRenderer.on 'user-result', (event, arg) ->
      actions.updateUser(arg)
}

view = (state, actions) ->
  oncreate = ->
    actions.watchUser()
    actions.user(window.location.search.slice(1))
  content = if state.user?
    <div key="user">
      <p>{state.dn}</p>
      {}
      <table>
        {
          for key, value of state.user
            <tr key={key}>
              <th>{key}</th>
              <td>{value}</td>
            </tr>
        }
      </table>
    </div>
  else
    <div key="none">
      {state.error ? '読み込み中。。。'}
    </div>
  <main class="container" oncreate={oncreate}>
    {content}
  </main>

app(state, actions, view, document.body)
