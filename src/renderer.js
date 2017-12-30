var action, searchTypes, state, view;

import {
  h
} from 'hyperapp';

state = {
  filter: '()'
};

action = {};

searchTypes = {
  hoge: 2
};

view = function(state, actions) {
  return <main>
    <label>名前(ja)</label>
    <input type="text" />
  </main>;
};

app(state, actions, view, document.body);
