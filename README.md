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
$ macaron macros.coffee main.coffee
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

### Basic Compilation

It basically replaces the code with the macro code.

```javascript
// $ macaron examples/macros.coffee examples/source.coffee
var x, y, _tmp$1;
x = 1;
y = 2;
console.log("before swap, x is " + x + ", y is " + y);

// swap x, y macro starts here
_tmp$1 = y;
y = x;
x = _tmp$1;
// ends here

console.log("after swap, x is " + x + ", y is " + y);
```

### Using Code Blocks

You can also use code blocks to use efficiently. To do this, just use splats
of CoffeeScript (`...`)

```coffeescript
macro.scope = (block...)->
  hello = "world"
  do ->
    block
```

Then you can simply call like a callback

```coffeescript
scope ->
  console.log hello
```

It will generate that code:

```javascript
var hello;

hello = "world";
(function() {
  return console.log(hello);
})();
```

### Composing

You can compose macros.

```coffeescript
macro.sayHello = (world)->
  hello = "world"
  world = "hello"
  swap hello, world # Calling Scope Macro
  console.log hello, world
```

### Hygiene

You can keep your variables safe using `$` prefix on your variables.

```coffeescript
# macros.coffee
macro.swap = (x, y)->
  $tmp = y
  y = x
  x = $tmp
```

```coffeescript
# main.coffee
x = 2
y = 3
swap x, y
console.log $tmp
```

When you run it, it will generate an error:
```
ReferenceError: $tmp is not defined
```
