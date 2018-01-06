import {h, app} from 'hyperapp'
import {ipcRenderer} from 'electron'
import login, {Login} from './renderer/login'
import search, {Search} from './renderer/search'

state = {
  login.state...
  search.state...
}

actions = {
  login.actions...
  search.actions...
}

view = (state, actions) ->
  mainElement = if state.loginStatus == 'done'
    <Search
      filter={state.searchFilter}
      entries={state.searchEntries}
      error={state.searchError}
      search={actions.search}
      dispalyUser={actions.displayUser}
      watchSearch={actions.watchSearch}
    />
  else
    <Login
      status={state.loginStatus}
      error={state.loginError}
      login={actions.login}
      watchLogin={actions.watchLogin}
    />

  <main class="container">
    {mainElement}
  </main>

app(state, actions, view, document.body)
