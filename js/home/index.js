// Generated by CoffeeScript 1.6.2
(function() {
  var SCROLL_LIMIT, loginFormVisible, min;

  SCROLL_LIMIT = 140;

  min = false;

  loginFormVisible = false;

  toggle;

  $(function() {
    $('a[href="#"]').click(function() {
      return false;
    });
    $(window).scroll(function(e) {
      var $this, st;

      $this = $(this);
      st = $this.scrollTop();
      if (st <= SCROLL_LIMIT && min) {
        $('#page').removeClass('min-bar');
        min = false;
      } else if (st > SCROLL_LIMIT && !min) {
        $('#page').addClass('min-bar');
        min = true;
      }
    });
    $('#toggle').click(function() {
      $('#page').toggleClass('min-bar');
    });
    $('#user-btn').click(function() {
      var $loginForm;

      console.log(123);
      $loginForm = $('.site-user .login-form');
      if (loginFormVisible) {
        loginFormVisible = false;
        $loginForm.removeClass('open');
      } else {
        loginFormVisible = true;
        $loginForm.addClass('open');
      }
    });
    $('.pinned').pin({
      containerSelector: "#sidebar-container"
    });
  });

}).call(this);