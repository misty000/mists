ATTR_TRANSLATE = 'data-translate'

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

	parse: undefined

	clean: ($data)->
		$('[editable]',$data).removeAttr('editable')
		$('[class]', $data).removeAttr('class')
		return $data

	@nonsupport: ['pre']

#=========================================================================

class Editor
	constructor: ->
		@$field = $('textarea', @$input)
		self = @
		@$input.on('keypress', (e)->
			self.hide() if e.keyCode is 13 and e.ctrlKey
			self.hide(false) if e.keyCode is 27
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
			@$currElem.removeAttr(ATTR_TRANSLATE)
		else
			@$currElem.attr(ATTR_TRANSLATE, val)
		$(editor).trigger('saved',
		  target: @$currElem
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
			.val($elem.attr(ATTR_TRANSLATE))
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
$main = $('#main-container')
$raw = $('#raw', $main)
$processed = $('#processed', $main)

parser = new Parser
editor = new Editor

loadDoc = ->
	$.get('translate.txt', (data)->
		doc = parser.parse(data)
		$raw.html(doc)
	, 'html')

$ ->
	loadDoc()
	$(editor)
		.on('editing', ->
			$raw.addClass('editing'))
		.on('done', ->
			$raw.removeClass('editing'))
		.on('saved', (e, param)->
			console.log param)

$ ->
	$('body').on('keypress', (e)->
		editor.hide() if e.keyCode is 13 and e.ctrlKey
		editor.hide(false) if e.keyCode is 27
	)
	$main.on('click', 'a', ->
		return false
	)
	$raw.tooltip(
	  selector: Parser.nonsupport.join(',')
	  #		placement: 'right'
	  title: '不支持'
	  container: 'body'
	)
	$raw.on('click', '[editable]', ->
		return if editor.isEditing()
		editor.show(this)
	)
	$('#result')
		.on('show', ->
			$('textarea', this).val(parser.clean($raw.clone()).children().html())
			$('body').css('overflow', 'hidden'))
		.on('hidden', ->
			$('body').css('overflow', 'auto'))











