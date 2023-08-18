# holistic-ruby

`holistic-ruby` is a toy language server for the Ruby programming language.

## Installation for Sublime Text

1. Make sure you have the [LSP package installed](https://github.com/sublimelsp/LSP).
2. `$ gem install holistic-ruby`
3. Go to `Preferences > Package Settings > LSP > Settings` and add:

```json
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

## Why did I build "toy" language server?

I built it for myself and I'm the only one using it.
