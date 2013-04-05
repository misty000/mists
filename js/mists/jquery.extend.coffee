rneedsContext = jQuery.expr.match.needsContext

jQuery.fn.extend({
	###
    Tests whether a predicate holds for some of the elements of this list.
    ###
	exists: jQuery.fn.is
	###
    Tests whether a predicate holds for all elements of this list.
    ###
	forall: (selector) ->
		this.filter(selector).length is this.length
	###
    Selects all elements of this list which do not satisfy a predicate.
    ###
	filterNot: jQuery.fn.not
	###
    Applies a function f to all elements of this list.
	###
	foreach: jQuery.fn.each
	escapedHtml: ->
		html = (s)->
			s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
		html(@html())
})