ERRZLESS = ($$body) ->
	try
		$$body
	catch e
		console.log "Something didn't #{e}"