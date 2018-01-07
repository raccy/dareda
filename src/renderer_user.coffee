import {h, app} from 'hyperapp'
import {ipcRenderer} from 'electron'

state = {
  dn: undefined
  user: undefined
  error: undefined
}

actions = {
  updateUser: ({dn, user, error}) -> (state) ->
    {dn: dn, user: user, error: error}
  user: (dn) -> (state, actions) ->
    ipcRenderer.send 'user', dn: dn
    return
  watchUser: -> (state, actions) ->
    ipcRenderer.on 'user-result', (event, arg) ->
      actions.updateUser(arg)
    return
}

view = (state, actions) ->
  oncreate = ->
    actions.watchUser()
    actions.user(window.location.search.slice(1))
  <main class="container" oncreate={oncreate}>
    <div>
      <p>{state.dn ? '読み込み中'}</p>
      <table>
        {
          for key, value of state.user ? []
            <tr key={key}>
              <th>{key}</th>
              <td>{value}</td>
            </tr>
        }
      </table>
    </div>
  </main>

app(state, actions, view, document.body)
