# Macaron

Macros for CoffeeScript. Try online: [http://f.github.io/macaron/](http://f.github.io/macaron/)

## Installation

```bash
npm install macaron
```

### Using Macaron Grunt Task

Macaron has a [Grunt plugin](http://github.com/ahmet/grunt-macaron) written by [Ahmet Aygün](http://github.com/ahmet).

```bash
npm install grunt-macaron --save-dev
```

Please read the [README file of grunt-macaron](https://github.com/ahmet/grunt-macaron/blob/master/README.md) for installation instructions.

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
macaron [MACROS FILE] [SOURCE FILES...] [COFFEE OPTIONS]
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
# Create a macro named do_something which accepts a code block
macro.do_something = (block...)->
  hello = "world"
  do ->
    block
```

Then you can simply call like a callback

```coffeescript
# Call the macro with a code block
do_something ->
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

### Replace Macros

Replace macros are so stupid ones, you can just pass the code to *replace*.
The code won't be parsed by Macaron. To define replace macros, use `do` keyword.
This macro type doesn't take any parameters since there are no parse process.

```coffeescript
macro.strict = do ->
  "use strict"
```

You can use `do` keyword to call these macros:

```coffeescript
do strict
```

It will generate the output:

```coffeescript
"use strict";
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

#### Escape Hygiene

You can always disable hygiene using **fat-arrow** (`=>`) or just don't use `$` prefix.

```coffeescript
macro.swap = (x, y)=> # disabling hygienic variables
  $tmp = y
  y = x
  x = $tmp
```

### Literal Macros

You can use Literal macros using `literal` definition keyword. It takes two arguments,
one is a **regular expression**, another is the function.

```coffeescript
literal /(\w+) is (\w+) plus (\w+)/, (variable, first, second)->
  variable = first + second
    
literal /tell (.*) the (\w+)/, (channel, parameter)->
  channel parameters
```

With these **literal macros** you can now write some talkative declarations:

```coffeescript
"a is 3 plus 4"
"tell console.log the a"
```

It will generate the output:

```javascript
var a;
a = 3 + 4;
console.log(a);
```

You can wrap matches into quotes using `@` (`this`) prefix on parameters.

```coffeescript
literal /tell my (\w+) is (.*)/, (@key, @value)->
  user[key] = value
```

You can now use the macros easily:

```coffeescript
"tell my name is fka" #=> It will be compiled to `user["name"] = "fka"`
```


## Examples

```coffeescript
# macros.coffee
macro.each = (variable, name, eachBlock...)->
  value = variable
  value.forEach ->
    $item = arguments[0]
    name = $item
    eachBlock
```

Using this macro:

```coffeescript
each [1, 2, 3], item, ->
  console.log item
```

And it'll generate that code:

```javascript
value = [1, 2];
value.forEach(function() {
  var item, _item$2;
  _item$2 = arguments[0];
  item = _item$2;
  return console.log(item);
});
```

### Reading from STDIN

You can simply use standard input to run macaron:

```bash
echo "x = 1; y = 2; swap x, y; console.log x, y" | macaron -scb examples/macros.coffee | node
```

## Command Line Usage

```
Usage: coffee ./bin/macaron [MACRO FILE] [SOURCE FILES...] [OPTIONS]

Options:
  -b, --bare     [default: true]
  -c, --compile  [default: false]
  --concat       [string]  [default: true]
```

## TODO

  - Browserify Transform

## License

MIT: [f.mit-license.org][3]

### The Idea

> A fork of [davidpadbury/stirred-coffee][1], based on the [blog post][2] about it.

[1]: http://github.com/davidpadbury/stirred-coffee
[2]: http://blog.davidpadbury.com/2010/12/09/making-macros-in-coffeescript/
[3]: http://f.mit-license.org
