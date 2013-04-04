SCROLL_LIMIT = 140

min = false
loginFormVisible = false

toggle

$ ->
	$('a[href="#"]').click(->
		return false
	)

	$(window).scroll((e)->
		$this = $(this)
		st = $this.scrollTop()
		if st <= SCROLL_LIMIT and min
			$('#page').removeClass('min-bar')
			min = false
		else if st > SCROLL_LIMIT and not min
			$('#page').addClass('min-bar')
			min = true
		return
	)

	$('#toggle').click(->
		$('#page').toggleClass('min-bar')
		return
	)

	$('#user-btn').click(->
		console.log 123
		$loginForm = $('.site-user .login-form')
		if loginFormVisible
			loginFormVisible = false
#			$loginForm.css('display', 'none')
			$loginForm.removeClass('open')
		else
			loginFormVisible = true
#			$loginForm.css('display', 'block')
			$loginForm.addClass('open')
		return
	)

	$('.pinned').pin({
	containerSelector: "#sidebar-container"
	})
	return