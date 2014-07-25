Macaron = require '../lib/index.coffee'
macros = new Macaron
compiledJS = macros.compileFile "#{__dirname}/macros.coffee", "#{__dirname}/source.coffee", bare: yes

console.log compiledJS
