import { h } from 'hyperapp'

InputUsername = ->
  <fieldset>
    <label for="login-username">ユーザー名</label>
    <input
      id="login-username"
      name="username"
      type="text"
      require={true}
      pattern="[\w-]+"
    />
  </fieldset>

InputPassword = ->
  <fieldset>
    <label for="login-password">パスワード</label>
    <input
      id="login-password"
      name="password"
      type="password"
      require={true}
    />
  </fieldset>


export default Login = ({login}) ->
  <div>
    <h2>ログイン</h2>
    <form onsumbit={(event) ->
      event.preventDefault()
      login
        username: event.target.username.value
        password: event.target.password.value
      # reset password
      event.target.password.value = ''
    }>
      <InputUsername />
      <InputPassword />
      <button type="submit">ログイン</button>
    </form>
  </div>
