fs = require 'fs'
coffee = require 'coffee-script'

module.exports = class Macaron

  hygienicVariableTemplate: (name, id)-> "_#{name}$#{id}"

  constructor: (@options)->

  compileSource: (macroSource, mainSource, options)->
    @macros = @parseMacros macroSource
    @literals = @parseLiterals macroSource
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
    @walkAndReplace @mainNodes, @literalize.bind(this)
    @mainNodes.compile options

  parseMacros: (source)->
    macros = {}
    nodes = @getNodes source
    nodes.expressions.forEach (node) =>
      if node.variable.base.value is 'macro'
        name = node.variable.properties?[0]?.name?.value.toString()
        macros[name] = node.value
    macros

  parseLiterals: (source)->
    literals = []
    nodes = @getNodes source
    nodes.expressions.forEach (node) =>
      if node.variable.base.value is 'literal'
        regexp = new RegExp "^#{(node.args[0]?.base?.value?.replace? /^\/|\/$/g, '')}$"
        literals.push [regexp, node.args[1]]
    literals

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

  literalize: (node, replace) ->
    return if node.constructor.name isnt 'Literal'

      args = {}

      for [literal, macro] in @literals
        _matches = node.base?.value?.replace?(/^["']|["']$/g, '').match literal
        continue unless _matches
        _matches.shift()
        matches = (arg for arg in _matches)

        macro = Cloner.clone macro
        for param, i in macro.params
          name = if param.name.this
            param.name.properties?[0]?.name?.value
          else
            param.name.value

          args[name] = [matches[i], param.name.this]

        @walkAndReplace macro, (node, replace) =>
          return if node.constructor.name isnt 'Value'
          ref = node.base?.value
          if args[ref] instanceof Array
            [arg, isString] = args[ref]
            if arg
              arg = "\"#{arg}\"" if isString
              replace @getNodes arg
      
        replace macro.body

  macroize: (node, replace) ->
    return if node.constructor.name isnt 'Call'

    name = node.variable?.base?.value
    return unless @macroExists name

    macro = Cloner.clone @macros[name]

    args = {}
    vars = {}
    
    macroType = macro.variable?.base?.value

    macroBody = switch yes
      # Direct Macros
      when macro.do
        macro.variable?.body

      # Another case
      else
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
          # macro.bound checks if fat-arrow used.
          else if ref?.indexOf('$') is 0 and not macro.bound
            name = ref.substring 1
            name = vars[name] or= @generateHygienicName name
            node.base.value = name
        macro.body

    replace macroBody

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

# Cloner Class

class Cloner
  
  @clone: (object)->
    switch typeof object
      when 'undefined', 'number', 'string', 'boolean', 'function'
        object
      when 'object'
        cloner = if object instanceof Array then 'array' else 'object'
        Cloner[cloner] object
      else
        console.log "Non-clonable #{typeof object}"

  @array: (data=[])-> Cloner.clone item for item in data
  
  @object: (data={})->
    cloned = {}
    for key, value of data
      cloned[key] = Cloner.clone value
    cloned.constructor = data.constructor
    cloned.__proto__ = data.__proto__
    cloned
  
if window? then window.Macaron = Macaron
