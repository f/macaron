# Macaron

Macros for CoffeeScript.

> A fork of [davidpadbury/stirred-coffee][1], based on the [blog post][2] about it.

[1]: http://github.com/davidpadbury/stirred-coffee
[2]: http://blog.davidpadbury.com/2010/12/09/making-macros-in-coffeescript/

## Installation

```bash
npm install macaron
```

## Overview

Create a Macro library:
```coffeescript
# macros.coffee
macro.swap = (x, y)->
  $tmp = y
  y = x
  x = $tmp
```

Write your Coffee using macros like functions:
```coffeescript
# main.coffee
x = 1
y = 2
console.log "before: x is #{x}, y is #{y}"
swap x, y
console.log "after: x is #{x}, y is #{y}"
```

Compile them on Terminal ..:
```bash
$ macaron macros.coffee main.coffee | node
before: x is 1, y is 2
after: x is 2, y is 1
```

.. Or in your CoffeeScript Code:
```coffeescript
# mycoffee.coffee
Macaron = require 'macaron'
macros = new Macaron
compiledJS = macros.compileFile 'macros.coffee', 'main.coffee', bare: no

console.log compiledJS
```

```bash
coffee mycoffee.coffee
```

## Usage

```bash
macaron [MACROS FILE] [SOURCE FILE] [COFFEE OPTIONS]
```
