$ ->
	$rect = $('#rect')
	$left = $('#left')
	$top = $('#top')
	$(window).scroll(->
		offset = $rect.offset()
		$left.text(offset.left)
		$top.text(offset.top)
		return
	)
	$('#side1').pin({
	containerSelector: '.container'
	})
	$('#side2').pin({
	containerSelector: '.container'
	})
	return