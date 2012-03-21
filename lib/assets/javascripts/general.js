
// gmail-like flash messages
// The sfclass cann be 'success' or 'error'
var hideMessageTimeout = null;
function showMessage(sfclass, sftext) {
	// Clear previous timeout if there was one
	// This way it will always stay x seconds
	window.clearTimeout(hideMessageTimeout);
	// Set it to disappear after x seconds
	hideMessageTimeout = window.setTimeout("$('#system-messages').animate({'margin-top': '-32px', 'opacity': '0'}, 'slow');", 6000);
	// Remove all previous classes and add new class
	$('#system-messages').animate({"margin-top": "0px", "opacity": "100"}, "fast");
	$('div p', '#system-messages').text(sftext);
	$('div', '#system-messages').removeClass('success error').addClass(sfclass);
}

$(document).ready(function(){
  
  $('a.colorbox-trigger').colorbox({inline:true, title:' ', maxWidth:'500px', opacity:0.7});
  
  // Add the "lass" class to the two last li items of a filter, to remove bottom borders
  $('ul.filter-option').each(function(){
    var li_count = parseInt($(this).find('li').length);
    var li_remainder = li_count % 2;
    var li_selector_gt = li_count-3+li_remainder;
    if (li_selector_gt > 0) {
      var li_selector = 'li:gt(' + li_selector_gt + ')';
    } else {
      var li_selector = 'li';
    }
    $(this).find(li_selector).addClass('last');
  })
  
            
          
  // Dropdown with selectable filters - filters' behaviour
  $('.dropdown ul a').click(function(){
    $(this).parent().toggleClass('selected');
    // return false;
    });
  
  // Dropwdown functionality
  $('.dropdown-button').click(function() {
    
    var this_a = $(this);
    var this_parent = this_a.parent();
    var this_submenu = this_a.next();
    
    // Hide all open submenus first
    if (!this_parent.hasClass('selected')) {
      $('.dropdown').removeClass('selected');
      $('.dropdown ul').fadeOut('fast');
    }
    
    // Show/hide the current submenu
    this_parent.toggleClass('selected');
    this_submenu.animate({
      "height": "toggle", "opacity": "toggle"
    }, "fast");
    
    // Reposition clipped dropdowns
    var parent = $(this).parents('.dropdown-container');
    if (parent.length) {
	    var this_right = this_submenu.offset().left + parseInt(this_submenu.width());
	    var parent_right = parent.offset().left + parent.width();
	    
	    if (this_right > parent_right) {  	      
	      var new_left = parent_right - this_right - 2;
	      this_submenu.css('left', new_left + 'px');
      }
    }
    
    // On mousleave of the submenu, hide it and the trigger
    this_submenu.mouseleave(function() {
      //console.log(this_submenu.offset().left);
      this_parent.removeClass('selected');
      this_submenu.fadeOut('fast');
      });
      
    return false;
    
    });
});