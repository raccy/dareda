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
      if status == 'success'
        actions.updateLoginError(undefined)
        actions.updateLoginStatus('done')
      else
        actions.updateLoginError(error)
        actions.updateLoginStatus('waiting')
}

InputUsername = ({disabled}) ->
  <div class="form-group">
    <div class="col-3">
      <label class="form-label" for="login-username">ユーザー名</label>
    </div>
    <div class="col-9">
      <input id="login-username" class="form-input" name="username"
        type="text" require={true} pattern="[\w-]+" disabled={disabled}
        oncreate={(element) -> element.focus()} />
    </div>
  </div>

InputPassword = ({disabled}) ->
  <div class="form-group">
    <div class="col-3">
      <label class="form-label" for="login-password">パスワード</label>
    </div>
    <div class="col-9">
      <input id="login-password" class="form-input" name="password"
        type="password" require={true} disabled={disabled} />
    </div>
  </div>

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
  disabled = status != 'waiting'
  <div key="login" id="login" oncreate={watchLogin}>
    <h2>ログイン</h2>
    <LoginError error={error} />
    <form class="form-horizontal" onsubmit={onsubmit}>
      <fieldset>
        <InputUsername disabled={disabled} />
        <InputPassword disabled={disabled} />
        <div class="form-group">
          <div class="col-9 col-ml-auto">
            <button class="btn" type="submit" disabled={disabled}>
              ログイン
            </button>
          </div>
        </div>
      </fieldset>
    </form>
  </div>

export default {
  state: state
  actions: actions
  Login: Login
}
