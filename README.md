# holistic-ruby

`holistic-ruby` is a toy language server for the Ruby programming language.

## Installation for Sublime Text

1. Make sure you have the [LSP package installed](https://github.com/sublimelsp/LSP).
2. Install the gem with `$ gem install holistic-ruby`
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

* Go to definition.
* Find references.
* Autocompletion for namespaces and methods.
* (WIP) Outline dependencies.
* (WIP) Syntax highlighting boundaries based on packwerk.
* (WIP) Glossary.

## Why is it a toy language server?

I use `holistic-ruby` on a daily basis while working in a fairly large Ruby codebase. It seems stable and speedy. But... I built it for myself and I'm the only one using it :smile:
