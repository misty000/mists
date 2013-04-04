IGNORE_SELECTOR = 'strong'

isleaf = (elems) ->
	$elems = elems
	$elems = $(elems) unless elems?.jquery?
	f = $elems.filter(->
		this.nodeType isnt 3 and not $(this).is(IGNORE_SELECTOR)
	)
	f.size() is 0


$ ->
	$contents = $('#t1').contents()
	$merge = $()
	for e in $contents
		$e = $(e)
		console.log e.nodeName

		if e.nodeName is 'BR'
			console.log $e.css('display')

		if e.nodeType is 3 or $e.css('display') isnt 'block'
			console.log 'if'
			$merge = $merge.add($e)
		else
			if $merge?
				console.log 'wrap'
				console.log $merge
				$merge.wrapAll('<p/>')
				$merge = $()
	$merge.wrapAll('<p/>')
	console.log $merge

	return
