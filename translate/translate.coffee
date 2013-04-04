DATA_ATTR_NAME = 'data-translate'
DATA_ORIGINAL_NAME = 'data-original'
ATTACH_ATTR_HEIGHT = 'attach_height'

ORIGINAL_ID_PREFFIX = 'otrans_'
TARGET_ID_PREFFIX = 'ttrans_'

#css classes
EDITING_CSS = 'editing'
EDITING_ITEM_CSS = 'editing-item'
HOVER_CSS = 'hover'

#class selectors
EDITING_SELECTOR = '.editing'
EDITING_ITEM_SELECTOR = '.editing-item'


selector = 'h1,h2,h3,h4,h5,h6,p,dt,dd,li'

$htmldoc = $('#step1 textarea')

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
	$textarea.bind('keypress', (e) ->
		stopEdit() if e.keyCode is 13 and e.ctrlKey
		stopEdit(false) if e.keyCode is 27
	)

$ ->
	$original.on('click', selector, originalClick)
	$('#startBtn').click(start)
	$('#gotoStep1Btn').click(gotoStep1)
	$('#saveBtn').click(save)
	$('#cancelBtn').click(cancel)
	$('#showResult').click(->
		stopEdit()
		$rs = $original.clone()
		$('#input', $rs).remove()
		$('*', $rs).removeAttr('id')
		$resultText.val($rs.html())
		$result.slideDown()
		return
	)
	$('#hideResult').click(->
		$result.slideUp()
		return
	)
	$compare.prop('checked', true)
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
	#加载数据
	$.get('translate.txt', (respText)->
		$htmldoc.val(respText)
		return
	, 'html')

gotoStep1 = ->
	$('#step1').slideDown()
	$('#step2').slideUp()
	return

start = ->
	$content = $('<div class="wrapper"/>').html($htmldoc.val())
	#移除脚本
	$('script', $content).remove()
	#移除class和id
	id = 1
	$('*', $content)
		.removeAttr('class')
		.removeAttr('id')
		.each(->
			$(this).attr('id', ORIGINAL_ID_PREFFIX + (id++))
		)
	#屏蔽链接
	$('[href]', $content).attr('href', 'javascript://')
	$original.html($content.contents())
	compareDirty = true
	$compare.change()
	$('#step1').slideUp()
	$('#step2').slideDown()
	return

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
	h = $current.height()
	$textarea.height(h)

	value = $current.attr(DATA_ATTR_NAME)
	$textarea.val(value ? '')

	$current.append($input)
	$input.finish()
	$input.fadeIn()
	$textarea.get(0).focus()
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
	return unless compareDirty
	$rs = $original.clone()
	$('#input', $rs).remove()

	for elem in $('[' + DATA_ATTR_NAME + ']', $rs)
		$e = $(elem)
		value = $.trim($e.attr(DATA_ATTR_NAME))
		$e.text(value) unless value is ''
		id = $e.attr('id')
		console.log h = $('#'+id, $original).height()
		$e.height(h)
	$target.html($rs.html())
	compareDirty = false
	return

#跨域访问，这种方式无效
getIframeDocument = (iframe)->
	return iframe.contentDocument if iframe.contentDocument?
	return iframe.contentWindow.document if iframe.contentWindow?
	return iframe.document if iframe.document?


















