macro.swap = (x, y)->
	$tmp = y
	y = x
	x = $tmp

macro.each = (variable, name, block...)->
	value = variable
	value.forEach ->
		$item = arguments[0]
		name = $item
		block
