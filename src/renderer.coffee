import {h, app} from 'hyperapp'
import {ipcRenderer} from 'electron'
import login, {Login} from './renderer/login'
import search, {Search} from './renderer/search'

state = {
  login.state...
  search.actions...
}

actions = {
  login.actions...
  search.actions...
}

view = (state, actions) ->
  mainElement = if state.loginStatus is 'done'
    <Search filterList={state.filterList} filterText={state.filterText}/>
  else
    <Login error={state.loginError} status={state.loginStatus}
      login={actions.login}  watchLogin={actions.watchLogin} />

  <main>
    {mainElement}
  </main>

app(state, actions, view, document.body)
