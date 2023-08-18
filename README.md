# holistic-ruby

`holistic-ruby` is a toy language server for the Ruby programming language.

## Installation for Sublime Text

1. Make sure you have the LSP package installed.
2. `$ gem install holistic-ruby`
3. Go to `Preferences > Package Settings > LSP > Settings` and add:

```
{
  "clients": {
    "holistic-ruby": {
      "enabled": true,
      "command": ["holistic-ruby"],
      "selector": "source.ruby | text.html.ruby",
      "initializationOptions": {}
    }
  }
}
```

## Features

* Go to definition
* Find references
* Autocompletion
* Package boundaries syntax highlighting, based on packwerk.
