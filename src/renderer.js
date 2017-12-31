var Input, actions, searchTypes, state, view;

import {
  h
} from 'hyperapp';

state = {
  filterText: '',
  filterList: []
};

actions = {
  setFilter: function(attribute, value) {
    return function(state, actions) {
      var filter, filterList;
      filterList = (function() {
        var i, len, ref, results;
        ref = state.filterList;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          filter = ref[i];
          if (filter.attribute !== attribute) {
            results.push(filter);
          }
        }
        return results;
      })();
      return actions.updateFilter();
    };
  },
  updateFilter: function() {
    return function(state) {
      var attribute, i, len, ref, results;
      ref = state.filterList;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        ({attribute} = ref[i]);
        if (filter.value) {
          results.push(`~=`);
        }
      }
      return results;
    };
  }
};

searchTypes = [
  {
    id: 'uid',
    name: 'アカウント名',
    atrribute: 'uid',
    type: 'text',
    pattern: /[\w-]+/,
    praceholder: 'username...'
  }
];

Input = function({id, name, attribute, type, pattern, praceholder, updateFilter}) {
  return <div>
    <label>{`${name}(${attribute})`}</label>
    <input key={id} type={type} pattern={pattern} praceholder={placeholder} onchange={function({
        target: {value}
      }) {
      return updateFilter(attribute, value);
    }} />
  </div>;
};

view = function(state, actions) {
  return <main>
    <label>名前(ja)</label>
    <input type="text" />
  </main>;
};

app(state, actions, view, document.body);
