fs = require 'fs'
coffee = require 'coffee-script'
nodes = require 'coffee-script/nodes'
clone = (require './lib/clone').clone

# Grab source
macroSource = (fs.readFileSync process.argv[0]).toString()
mainSource = (fs.readFileSync process.argv[1]).toString()

# Compile source to nodes
macroNodes = coffee.nodes coffee.tokens macroSource
mainNodes = coffee.nodes coffee.tokens mainSource

# Store all Macros by name
macros = {}

macroNodes.expressions.forEach (node) ->
	name = node.variable.base.value
	code = node.value
	macros[name] = code
		

# Walk main node tree
replacingWalk = (node, visitor) ->
	return if not node.children
	
	node.children.forEach (childName) ->
		child = node[childName]
		
		return unless child
			
		if child instanceof Array
			# There really must be a way to do a normal for loop
			i = 0
			while i < child.length
				visitor child[i], (replacement) ->
					child[i] = replacement
				
				replacingWalk child[i], visitor
				i++
		else
			visitor child, (replacement) ->
				child = node[childName] = replacement
			
			replacingWalk child, visitor

# Test for macro replacement
macroize = (n, replace) ->
	return if n.constructor != nodes.Call

	name = n.variable?.base?.value
	return if not name or not macros[name]
	console.log macros[name].toString()
	macro = clone macros[name]
	console.log macro.toString()
	args = {}

	for param, i in macro.params
		name = param.name.value
		args[name] = n.args[i]

	replacingWalk macro, (node, replace) ->
		return if node.constructor != nodes.Value
		ref = node.base?.value
		return if not args[ref]
		replace args[ref]

	replace macro.body
				
replacingWalk mainNodes, macroize

js = mainNodes.compile { bare: true }

console.log js