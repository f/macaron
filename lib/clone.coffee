# This is probably a horribly awful idea
cloneArray = (a) ->
	n = []
	i = 0
	while i < a.length
		n[i] = clone a[i]
		i++
	n
	
cloneObj = (o) ->
	c = {}
	for key, value of o
		c[key] = clone value
	c.constructor = o.constructor
	c.__proto__ = o.__proto__
	c
	
clone = (o) ->
	switch typeof o
		when 'undefined', 'number', 'string', 'boolean', 'function' then o
		when 'object'
			if o instanceof Array
				cloneArray o
			else
				cloneObj o
		else console.log "found non-cloneable type: #{typeof o}"
		
exports.clone = clone