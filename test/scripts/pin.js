// Generated by CoffeeScript 1.6.2
(function() {
  $(function() {
    var $left, $rect, $top;

    $rect = $('#rect');
    $left = $('#left');
    $top = $('#top');
    $(window).scroll(function() {
      var offset;

      offset = $rect.offset();
      $left.text(offset.left);
      $top.text(offset.top);
    });
    $('#side1').pin({
      containerSelector: '.container'
    });
    $('#side2').pin({
      containerSelector: '.container'
    });
  });

}).call(this);