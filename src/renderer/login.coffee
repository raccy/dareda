import {h} from 'hyperapp'
import {ipcRenderer} from 'electron'

export state = {
  loginStatus: 'waiting'
  loginError: undefined
}

export actions = {
  updateLoginStatus: (loginStatus) -> (state) ->
    {loginStatus: loginStatus}
  updateLoginError: (error) -> (state) ->
    {loginError: error}
  login: ({username, password}) -> (state, actions) ->
    actions.updateLoginStatus('running')
    actions.updateLoginError('ログイン中・・・')
    ipcRenderer.send 'login', {username: username, password: password}
    return
  watchLogin: -> (state, actions) ->
    ipcRenderer.on 'login-result', (event, {status, error}) ->
      if status is 'success'
        actions.updateLoginError(undefined)
        actions.updateLoginStatus('done')
      else
        actions.updateLoginError(error)
        actions.updateLoginStatus('waiting')
}

InputUsername = ({disabled}) ->
  <fieldset>
    <label for="login-username">ユーザー名</label>
    <input
      id="login-username"
      name="username"
      type="text"
      require={true}
      pattern="[\w-]+"
      disabled={disabled}
    />
  </fieldset>

InputPassword = ({disabled}) ->
  <fieldset>
    <label for="login-password">パスワード</label>
    <input
      id="login-password"
      name="password"
      type="password"
      require={true}
      disabled={disabled}
    />
  </fieldset>

LoginError = ({error}) ->
  if error?
    <div>
      {error}
    </div>
  else
    <div>
      ユーザー名とパスワードを入力してください。
    </div>

export Login = ({error, status, login, watchLogin}) ->
  onsubmit = (event) ->
    event.preventDefault()
    login({
      username: event.target.username.value
      password: event.target.password.value
    })
    # reset password
    event.target.password.value = ''
  disabled = status isnt 'waiting'
  <div id="login" oncreate={watchLogin}>
    <h2>ログイン</h2>
    <LoginError error={error} />
    <form onsubmit={onsubmit}>
      <InputUsername disabled={disabled} />
      <InputPassword disabled={disabled} />
      <button type="submit" disabled={disabled}>ログイン</button>
    </form>
  </div>

export default {
  state: state
  actions: actions
  Login: Login
}
