DATA_ATTR_NAME = 'data-translate'
DATA_ORIGINAL_NAME = 'data-original'

#css classes
EDITING_CSS = 'editing'
EDITING_ITEM_CSS = 'editing-item'
HOVER_CSS = 'hover'

#class selectors
EDITING_SELECTOR = '.editing'
EDITING_ITEM_SELECTOR = '.editing-item'


selector = 'h1,h2,h3,h4,h5,h6,p,dt,dd,li'

$main = $('#main')
$original = $('#trans-original')
$target = $('#trans-target')

$input = $('#input')
$textarea = $('#textarea')

$autoSave = $('#autoSave')
$compare = $('#compare')

$result = $('#result')
$resultText = $('textarea', $result)

$currEditingItem = null

compareInterval = null
compareDirty = false

$ ->
	$.get('translate.txt', (respText, status)->
		$content = $('<div class="wrapper"/>').html(respText)
		$('*', $content)
			.removeAttr('class')
			.removeAttr('id')
		$('[href]', $content).attr('href', 'javascript://')
		$original.html($content.children())
		return
	, 'html')
	$original
		.on('click', selector, originalClick)
	$('#saveBtn').click(save)
	$('#cancelBtn').click(cancel)
	$('#showResult').click(->
		stopEdit()
		$rs = $original.clone()
		$('#input', $rs).remove()
		$resultText.val($rs.html())
		$result.slideDown()
		return
	)
	$('#hideResult').click(->
		$result.slideUp()
		return
	)
	$compare.prop('checked', false)
	$compare.change(->
		needCompare = $compare.prop('checked')
		if needCompare and not compareInterval?
			$main.addClass('split')
			compareDirty = true
			compare()
			compareInterval = setInterval(compare, 1000)
		else if not needCompare and compareInterval
			$main.removeClass('split')
			clearInterval(compareInterval)
			compareInterval = null
		return
	)


save = ->
	stopEdit(true)
	return false

cancel = ->
	stopEdit(false)
	return false


startEdit = ->
	return unless $currEditingItem?
	$current = $currEditingItem

	$current.addClass(EDITING_ITEM_CSS)
	$original.addClass(EDITING_CSS)

	value = $current.attr(DATA_ATTR_NAME)
	$textarea.val(value ? '')

	$current.append($input)
	$input.finish()
	$input.fadeIn()
	return

stopEdit = (save = true) ->
	return unless $currEditingItem?
	$current = $currEditingItem
	$input.fadeOut()
	$current.removeClass(EDITING_ITEM_CSS)
	$original.removeClass(EDITING_CSS)
	if save
		$current.attr(DATA_ATTR_NAME, $textarea.val())
		compareDirty = true
	$currEditingItem = null
	return

originalMouseEnter = ->
	$(this).addClass(HOVER_CSS)
	return

originalMouseLeave = ->
	$(this).removeClass(HOVER_CSS)
	return

originalClick = ->
	$this = $(this)
	return if $this.is($currEditingItem)
	autoSave = $autoSave.prop('checked')
	stopEdit(autoSave) if $currEditingItem?
	$currEditingItem = $this
	startEdit()
	return

compare = ->
	if compareDirty
		$rs = $original.clone()
		$('#input', $rs).remove()

		for elem in $('[' + DATA_ATTR_NAME + ']', $rs)
			$e = $(elem)
			value = $.trim($e.attr(DATA_ATTR_NAME))
			$e.text(value) unless value is ''
		$target.html($rs.html())
		compareDirty = false











