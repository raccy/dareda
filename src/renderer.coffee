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
    <Search filterText={state.filterText} results={state.searchResults}
      search={actions.search} watchResult={actions.watchResult}/>
  else
    <Login error={state.loginError} status={state.loginStatus}
      login={actions.login}  watchLogin={actions.watchLogin} />

  <main class="container">
    {mainElement}
  </main>

app(state, actions, view, document.body)
