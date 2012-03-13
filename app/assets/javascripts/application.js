//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jquery.colorbox
//= require jquery.qtip-1.0.0-rc3.min
//= require jquery.tableofcontents.min
//= require fullcalendar
//= require pretty
//= require notifications
//= require predictions
//= require calendar
//= require general
//= require_self
//= require manybots.omnisearch

$(document).ready(function() {

	$('a.go-to-app').click(function() {
		$(this).attr('target', '_blank');
	});
  
  $('a.activity.add.verb').click(function(){
    var verb = prompt("What verb would you like to create?", "");
    if (verb != null){
      $.ajax({
        type: 'POST',
        url: '/verbs.json',
        data: { 
          verb: {
            name: verb
          }
        },
        success: function(data) {
          var $new_option = $('<option/>').attr('value', data.verb.url_id).attr('selected', 'selected').text(data.verb.name);
          $('#activity_verb').append($new_option);
        },
        error: function(data){
          alert('Sorry, there was an error');
        }        
      });
    }
    return false;
  });
  
  $('a.activity.add.object_type').click(function(){
    var ot = prompt("What Object Type would you like to create?", "");
    if (ot != null){
      var $objectSelect = $('#activity_object_attributes_object_type');
      var $targetSelect = $('#activity_target_attributes_object_type');
      var $link = $(this);
      $.ajax({
        type: 'POST',
        url: '/object_types.json',
        data: { 
          object_type: {
            name: ot
          }
        },
        success: function(data) {
          var $new_option = $('<option/>').attr('value', data.object_type.url_id).attr('selected', 'selected').text(data.object_type.name);
          if ($link.attr('rel') == 'target') {
            $targetSelect.append($new_option.clone().attr('selected', 'selected'));
            $objectSelect.append($new_option.clone());
          } else {
            $objectSelect.append($new_option.clone().attr('selected', 'selected'));
            $targetSelect.append($new_option.clone());
          }
        },
        error: function(data){
          alert('Sorry, there was an error');
        }        
      });
    }
    return false;
  });
  
  $('#preview_new_activity').live('click', function() {
    var $form = $('#new_activity');
    var data = $form.serialize();
    $.ajax({
      type: 'POST',
      url: "/activities/preview",
      data: data,
      success: function(data) {
        var title = $(data).find('div.activity.title').html();
        $('#preview').html(data);
        $('input#activity_title').attr('value', title);
        $('p.save').show();
        $('div#errorExplanation').remove();
      },
      error: function(data) {
        $('#simple_form').html(data.responseText);
        $error = $('<p />').html('There were errors in your activity, please scroll up to check and correct them.');
        $error.attr('style', 'color: red;');
        $('#preview').append($error);
      }
    });
    return false;
  });

	$('.help-read-on-open a').click(function() {
		$($(this).attr('rel')).show();
		$(this).parent().hide();
		return false;
	});
	
	$('.help-read-on-close a').click(function() {
		$($(this).attr('rel')).hide();
		$('.help-read-on-open').show();
		return false;
	});
	
	// Testimonials
	
  $('.quotation').each(function() {
    $(this).hide();
  });

  (function shownext(jq){
    jq.eq(0).fadeIn(500, function(){
      $(this).delay(5500).fadeOut(250, function() {
        if ((jq=jq.slice(1)).length == 0) 
         (jq=$('.quotation')).length && shownext(jq);
        else
         shownext(jq);
      });;
    });
  })($('.quotation'))
  
});

var addVerb = function() {
};