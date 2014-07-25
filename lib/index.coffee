fs 				  = require 'fs'
coffee 		  = require 'coffee-script'

module.exports = class Macaron

  hygienicVariableTemplate: (name, id)-> "_#{name}$#{id}"

  constructor: (@options)->

  compileSource: (macroSource, mainSource, options)->
    @macros = @parseMacros macroSource
    @mainNodes = @getNodes mainSource
    @compile options

  compileFile: (macroFile, mainFile, options)->
    @macros = @parseMacros @getSource macroFile
    @mainNodes = @getNodes @getSource mainFile
    @compile options

  compileFileAndRun: -> eval @compileFile arguments...
  compileSourceAndRun: -> eval @compileFile arguments...

  compile: (options=@options)->
    @walkAndReplace @mainNodes, @macroize.bind(this)
    @mainNodes.compile options

  parseMacros: (source)->
    macros = {}
    nodes = @getNodes source
    nodes.expressions.forEach (node) =>
      if node.variable.base.value is 'macro'
        name = node.variable.properties?[0]?.name?.value.toString()
        macros[name] = node.value
    macros

  walkAndReplace: (node, replacer) ->
    node.children?.forEach (childName) =>
      child = node[childName]
      return unless child

      if child.length?
        for grantChild, i in child
          replacer grantChild, (replacement) -> child[i] = replacement
          @walkAndReplace child[i], replacer
      else
        replacer child, (replacement) -> child = node[childName] = replacement
        @walkAndReplace child, replacer

  macroize: (node, replace) ->
    return if node.constructor.name isnt 'Call'

    name = node.variable?.base?.value
    return unless @macroExists name

    macro = Object.create @macros[name]

    args = {}
    vars = {}

    for param, i in macro.params
      name = param.name.value
      if param.splat
        # Unwrap body of expression
        args[name] = node.args[i].body
      else
        args[name] = node.args[i]

    @walkAndReplace macro, (node, replace) =>
      return if node.constructor.name isnt 'Value'
      ref = node.base?.value
      if args[ref]
        replace args[ref]
      else if ref?.indexOf('$') is 0
        name = ref.substring 1
        name = vars[name] or= @generateHygienicName name
        node.base.value = name

    replace macro.body

  getSource: (file)->
    fs.readFileSync(file).toString()

  getNodes: (source)->
    coffee.nodes coffee.tokens source

  macroExists: (name)->
    name? and @macros[name]?

  generateHygienicName: (name)->
    @hygieneId ?= 0
    @hygieneId++
    @hygienicVariableTemplate name, @hygieneId
