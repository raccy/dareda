searchTypes = [
  {
    id: 'uid'
    name: 'アカウント名'
    atrribute: 'uid'
    type: 'text'
    pattern: /[\w-]+/
    praceholder: 'username...'
  }
]

Input = ({id, name, attribute, type, pattern, praceholder, updateFilter}) ->
  <div>
    <label>{"#{name}(#{attribute})"}</label>
    <input
      key={id}
      type={type}
      pattern={pattern}
      praceholder={placeholder}
      onchange={({target:{value}}) ->
        updateFilter(attribute, value)
      }
    />
  </div>
