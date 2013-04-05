$ = jQuery
ATTR_TRANSLATE_KEY = 'data-translate'

DATA_COMPARE_KEY = 'trans-compare'

#=====================================================

class Parser
	constructor: ->
		__eachCallback = ->
			$this = $(@)
			$contents = $this.contents()
			#忽略没有内容的元素
			return if $contents.length is 0
			#如果子元素都是文本元素，则该元素是可编辑的
			textNodeOnly = $contents.forall(->
				this.nodeType is 3
			)
			if textNodeOnly
				$this.attr('editable', true)
				return

			#boolean,是否包含块级元素
			containBlock = $this.children().exists(->
				$(this).css('display') in ['block', 'list-item']
			)
			if containBlock
				#如果元素既有块级子元素，又有文本元素，则给文本元素加上包装
				$contents.filter(->
					this.nodeType is 3 and $.trim(this.nodeValue) isnt ''
				).wrap('<div editable=true/>')
			else
				#如果子元素没有块级元素，则该元素是可编辑的
				$this.attr('editable', true) unless containBlock
				return
			return
		__parse = (data)->
			$doc = $('<article/>').html(data)
			$('script', $doc).remove()
			$('*', $doc)
				.removeAttr('class')
				.removeAttr('id')
				.filterNot('img')
				.foreach(__eachCallback)
			$('[editable] [editable]', $doc).removeAttr('editable')
			#暂时不支持pre
			$(Parser.nonsupport.join(','), $doc)
				.removeAttr('editable')
			return $doc
		@parse = (data)->
			__parse(data)

	parse: (data)->
		return data if data?
		__eachCallback = ->
			$this = $(@)
			$contents = $this.contents()
			#忽略没有内容的元素
			return if $contents.length is 0
			#如果子元素都是文本元素，则该元素是可编辑的
			textNodeOnly = $contents.forall(->
				this.nodeType is 3
			)
			if textNodeOnly
				$this.attr('editable', true)
				return

			#boolean,是否包含块级元素
			containBlock = $this.children().exists(->
				$(this).css('display') in ['block', 'list-item']
			)
			if containBlock
				#如果元素既有块级子元素，又有文本元素，则给文本元素加上包装
				$contents.filter(->
					this.nodeType is 3 and $.trim(this.nodeValue) isnt ''
				).wrap('<div editable=true/>')
			else
				#如果子元素没有块级元素，则该元素是可编辑的
				$this.attr('editable', true) unless containBlock
				return
			return
		__parse = (data)->
			$doc = $('<article/>').html(data)
			$('script', $doc).remove()
			$('*', $doc)
				.removeAttr('class')
				.removeAttr('id')
				.filterNot('img')
				.foreach(__eachCallback)
			$('[editable] [editable]', $doc).removeAttr('editable')
			#暂时不支持pre
			$(Parser.nonsupport.join(','), $doc)
				.removeAttr('editable')
			return $doc
		__parse(data)

	clean: ($data)->
		__clean = ($d) ->
			$d.removeAttr('editable')
			$d.removeAttr('class')
		__clean($data)
		__clean($('[editable]', $data))
		__clean($('[class]', $data))
		$data

	convert: ($data)->
		$('[editable]', $data).foreach(->
			$this = $(this)
			val = $.trim($this.attr(ATTR_TRANSLATE_KEY) ? '')
			return if val is ''
			$this.html(val)
			$this.removeAttr(ATTR_TRANSLATE_KEY)
		)
		@clean($data)


	@nonsupport: ['pre']

#=========================================================================

class Editor
	constructor: ->
		@$field = $('textarea', @$input)
		self = @
		@$input.on('keypress', (e)->
			if e.keyCode is 13 and e.ctrlKey
				self.hide()
				return false
			if e.keyCode is 27
				self.hide(false)
		)
		@$input.on('click', 'button', ->
			$this = $(this)
			self.hide() if $this.is('.save')
			self.hide(false) if $this.is('.cancel')
		)

	$input: $('''
			  <div class="hero-unit" style="border:1px solid darkgrey; padding: 10px; position: absolute; display: none;">
			  <field>
			  <textarea class="input-block-level"></textarea>
			  <button class="save btn btn-primary">Save (Ctrl+Enter)</button>
			  <button class="cancel btn btn-danger">Cancel (Esc)</button>
			  </field>
			  </div>
			  ''')

	$field: null

	$currElem: null

	save: ->
		return unless @$currElem?
		val = $.trim @$field.val()
		if val is ''
			@$currElem.removeAttr(ATTR_TRANSLATE_KEY)
		else
			@$currElem.attr(ATTR_TRANSLATE_KEY, val)
		$(editor).trigger('saved',
		  $target: @$currElem
		  data: val
		)

	show: ($elem)->
		return if @$currElem?
		return unless $elem?
		self = @
		$elem = $($elem) unless $elem.jquery?
		$elem.addClass('editing')
		@$currElem = $elem
		$(this).trigger('editing')
		#location
		w = Math.max($elem.width(), 300)
		h = $elem.height()
		{left, top} = $elem.offset()
		@$field
			.width(w - 35)
			.height(h + 20)
			.val($elem.attr(ATTR_TRANSLATE_KEY))
		@$input
			.appendTo('body')
			.slideDown(->
				$(self).trigger('shown'))
			.offset({left, top: top + h + 5})
		@$field.get(0).focus()
		return

	hide: (save = true)->
		if  @$currElem?
			@save() if save
			@$currElem.removeClass('editing')
			$(this).trigger('done')
		@$field.val('')
		self = @
		@$input.slideUp(->
			self.$input.detach()
			self.$currElem = null
			$(self).trigger('hidden')
		)
		return

	isEditing: ->
		@$currElem?

#=========================================================================

class Progress
	constructor: ->
		__$bar= $('<div class="bar bar-success"></div>')
		__$text = $('<div>当前进度：<span>0</span>%</div>')
		__$value = $('span', __$text)
		__$progress = $('<div class="progress"/>')
			.append(__$bar)
			.add(__$text)
		@render = (selector)->
			return unless selector?
			$obj = $(selector)
			$obj.html(__$progress)
		@update = (value)->
			v = toDecimal(value)
			__$value.text(v)
			__$bar.css('width', v + '%')
	render: null
	update: null


#=========================================================================

$main = null
$raw = null
$processed = null

parser = new Parser
editor = new Editor
progress = new Progress

toDecimal = (x)->
	f = parseFloat(x)
	return 0 if isNaN(f)
	Math.round(f * 100) / 100

loadDoc = (data = null)->
	doc = parser.parse(data)
	$raw.html(doc)

removeCompare = ($target)->
	return unless $target?
	$target = $($target) unless $target.jquery?
	$compare = $target.data(DATA_COMPARE_KEY)
	$compare?.remove()
	$target.removeData(DATA_COMPARE_KEY)

compare = ($target)->
	return unless $target?
	$target = $($target) unless $target.jquery?
	removeCompare($target)
	val = $target.attr(ATTR_TRANSLATE_KEY)
	return unless val?
	$compare = parser.clean($target.clone())
	$compare.appendTo($processed)
	$compare.html(val)
	$target.data(DATA_COMPARE_KEY, $compare)
	#position
	offset = $target.offset()
	rawX = $raw.offset().left
	parentX = $processed.offset().left
	offset.left += parentX - rawX
	w = $target.width()
	h = $target.height()
	$compare
		.width(w)
		.height(h)
		.offset(offset)

updateCompare =->
	$('[editable]', $raw).foreach -> compare($(this))

updateProgress = ->
	total = $('[editable]', $raw).length
	done = $('[' + ATTR_TRANSLATE_KEY + ']', $raw).length
	progress.update(done / total * 100)

#Init
$ ->
	$main = $('#main-container')
	$raw = $('#raw', $main)
	$processed = $('#processed article', $main)

	$(editor)
		.on 'editing', ->
			$raw.addClass('editing')
			return
		.on 'done', ->
			$raw.removeClass('editing')
			return
		.on 'saved', (e, param)->
			compare(param.$target)
			updateProgress()
			return
	progress.render($('header'))

#Bind Event
$ ->
	#Resize Compare
	do ->
		resizeTimeout = null
		$(window).on 'resize', ->
			if resizeTimeout?
				clearTimeout(resizeTimeout)
				resizeTimeout = null
			resizeTimeout = setTimeout(->
				updateCompare()
			, 100)
	$('body').on 'keypress', (e)->
		if e.keyCode is 13 and e.ctrlKey
			editor.hide()
			return false
		if e.keyCode is 27
			editor.hide(false)
			return false

	$main.on 'click', 'a', ->
		false

	$raw
		.on 'click', '[editable]', ->
			return if editor.isEditing()
			editor.show(this)
			return
		.on 'mouseover', '[editable]', ->
			$(this).data(DATA_COMPARE_KEY)?.addClass('hover')
			return
		.on 'mouseleave', '[editable]', ->
			$(this).data(DATA_COMPARE_KEY)?.removeClass('hover')
			return
		.tooltip(
		  selector: Parser.nonsupport.join(',')
		  #		placement: 'right'
		  title: '不支持'
		  container: 'body'
		)

	$('#quit').click ->
		$input = $('#input')
		$input.modal('show')
		$raw.html('')
		$text = $('textarea', $input)
		$text.val('')
		$text.get(0).focus()

#Modal
$ ->
	#TODO
	###do###
	do ->
		$input = $('#input')
		$input
			.on 'click', 'button.btn-start', ->
				val = $('textarea', $input).val()
				loadDoc(val)
				updateCompare()
				updateProgress()
				$input.modal('hide')
				return
			.modal(
			  backdrop: 'static'
			  keyboard: false
			)

	$('#result')
		.on 'show', ->
			$('textarea', this).val(parser.clean($raw.clone()).children().html())
			$('body').css('overflow', 'hidden')
			return
		.on 'hidden', ->
			$('body').css('overflow', 'auto')
			return

#Debug
#$ ->
#	$.get('translate.txt', (data)->
#		loadDoc(data)
#		updateCompare()
#		updateProgress()
#	, 'html')

