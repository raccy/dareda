import { h } from 'hyperapp'

state = {
  filter: '()'
}

action = {

}

searchTypes = [
  {
    name: 'アカウント名'
    atrribute: 'uid'
    type: 'text'
    pattern: /[\w-]+/
  }
]




view = (state, actions) ->
  <main>
    <label>名前(ja)</label>
    <input
      type="text"
    />
  </main>

app(state, actions, view, document.body)
