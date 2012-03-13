// Manybots OmniSearch
// Copyright 2012 Alex Solleiro, Manybots

if(!Array.prototype.indexOf) {
    Array.prototype.indexOf = function(needle) {
        for(var i = 0; i < this.length; i++) {
            if(this[i] === needle) {
                return i;
            }
        }
        return -1;
    };
}


$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});

var $wrapper,$result, $omnisearch, $loading;

var omniSearch = {};
omniSearch.currentSelection = 0;
omniSearch.currentUrl = '';
omniSearch.locked = false;
omniSearch.searches = 1;
omniSearch.emptySearches = {};
omniSearch.currentSearches = {};
omniSearch.queries = [];

omniSearch.incrementSearches = function(query) {
  if (omniSearch.currentSearches.hasOwnProperty(query))
    omniSearch.currentSearches[query] ++;
  else
    omniSearch.currentSearches[query] = 1;
  
  omniSearch.resetSearches(query);
}
omniSearch.resetSearches = function(query) {
  if (omniSearch.currentSearches[query] == omniSearch.searches) {
    omniSearch.emptySearches[query] = 0;
    omniSearch.currentSearches[query] = 0;
    omniSearch.locked = false;
  } 
  if (omniSearch.currentSearches[omniSearch.queries[-1]] == omniSearch.emptySearches[omniSearch.queries[-1]] == omniSearch.searches)
    $loading.html('No results found.');
}

omniSearch.emptySearch = function(query) {
  $loading.html('No results found for "'+ query + '".')
  omniSearch.filterDisplay($('#omnisearch').val(), true);
}


omniSearch.search = function(query) {  
  $.post('/search', query, function(results) {
    if (results)
      omniSearch.drawResults(results, query.type);
    else
      omniSearch.emptySearch(query.q);
  });
}

omniSearch.regex = function(query) {
  return new RegExp('\\b' + query.toLowerCase());
}

omniSearch.filterDisplay = function(query, affectLoading) {
  $('#omnisearch-results-activities').remove();
  $existing = $('li.omnisearch-result');
  $results.show();
  if ($existing.length != 0) {
    $.each($existing, function(i) {
      var $li = $($existing[i]);
      if ($li.attr('rel').toLowerCase().match(omniSearch.regex(query)) ) {
        $li.parent().parent().parent().show();
        $li.show();
        if (affectLoading == true)
          $loading.hide();
      } else {
        $li.hide();
        if ($li.parent().children('li:visible').length == 0)
          $li.parent().parent().parent().hide();
      }
    });
  }
}
omniSearch.drawResults = function(results, oldSearchType) {
  var searchTypes = [];
  var incoming = $(results);
  if (incoming.length > 1) {
    $.each($(incoming), function(i) {
      var list = $(incoming).eq(i);
      if (list.attr('id'))
        var searchType = list.attr('id').replace('omnisearch-results-', '');
      if (searchType)
        searchTypes.push(searchType);
    });
  } else {
    var searchType = incoming.attr('id').replace('omnisearch-results-', '');
    searchTypes.push(searchType);
  }
  for (var i = searchTypes.length - 1; i >= 0; i--){
    var searchType = searchTypes[i];
    if (searchType == 'activities') {
      $results.html(results);
      return false;  
    }
    var $exists = $('#omnisearch-results-'+searchType);
    var thisOne = incoming.siblings('#omnisearch-results-'+searchType);
    if ($exists.html() != null) {
      var $incoming;
      if (thisOne.length != 0)
        $incoming = $(thisOne).children('dd').first().children('ul').first().children('li');
      else
        $incoming = $(results).children('dd').first().children('ul').first().children('li');
      
      $.each($incoming, function(i) {
        var $li = $($incoming[i]);
        $exists = $('#omnisearch-results-'+searchType);
        var $identical = $($exists).children('dd').first().children('ul').first().children('li[rel="'+ $li.attr('rel') +'"]');
        if ($identical.length == 0) {
          $($exists).children('dd').first().children('ul').first().append($li);
        } 
      });
    } else {
      if (thisOne.length != 0)
        $results.append(thisOne);
      else
        $results.append(results);
    };
  };
  var query = $('#omnisearch').val();
  omniSearch.filterDisplay(query, true);
};

omniSearch.navigate_search_results = function(direction) {
  // Check if any of the menu items is selected
  if($("li.omnisearch-result.selected").size() == 0) {
    omniSearch.currentSelection = -1;
  }   
  if(direction == 'up' && omniSearch.currentSelection != -1) {
    if(omniSearch.currentSelection != 0) {
       omniSearch.currentSelection--;
    }
  }
  if (direction == 'down') {
    if(omniSearch.currentSelection != ($("li.omnisearch-result:visible").size()-1)) {
       omniSearch.currentSelection++;
    }
  }
  omniSearch.setSelected(omniSearch.currentSelection);
}

omniSearch.setSelected = function (current_result) {
	var $searchResults = $("li.omnisearch-result:visible");
	$searchResults.removeClass("selected");
  $searchResults.eq(current_result).addClass("selected");
  omniSearch.currentUrl = $searchResults.eq(current_result).children('a').first().attr("href");
}


omniSearch.runSearch = function(query) {
  if (query == '') {
    return false;
  } else {
    omniSearch.searches = 1;
    omniSearch.queries.push(query);
    
    // Search for apps
    var app = {
      type: 'all',
      q: query
    };
    omniSearch.search(app);
  }
}

omniSearch.delayed = null;
omniSearch.timer = 500;
omniSearch.delaySearch = function(query) {
  clearTimeout(omniSearch.delayed);
  omniSearch.delayed = setTimeout("omniSearch.runSearch($('#omnisearch').val())", omniSearch.timer);
}

$(function() {
  var query = '';
  
  $wrapper = $('.omnisearch-input').first();
  $results = $('<div />').attr('id', 'omnisearch-results');
  $omnisearch = $('#omnisearch');
  $loading = $('<div />').addClass('loading');
  
    
  $('#omnisearch').keyup(function(e) {
    // capture certain keys  
		// navigate through search results if user uses up/down arrows or enter 
		// reset the search field if user hits Escape
		//console.log(e.keyCode);
		switch(e.keyCode) { 
	    case 38: // UP arrow
	    	omniSearch.navigate_search_results('up');
	    	return false;
	    case 40: // DOWN arrow
				//console.log('navigating down');
	    	omniSearch.navigate_search_results('down');
		    return false;
	    case 13: // ENTER 
	    	if(omniSearch.currentUrl != '') {
	      	window.location = omniSearch.currentUrl;
	       }
				return false;
			case 27: // Escape key
			  $(this).val('');
			  $('#omnisearch-results-activities').remove();
        $results.hide();
				return false;
			case 39: // Arrow right
			  return false;
			case 37: // Arrow left
			  return false;
		}
    
    
    var currentQuery = $(this).val();
    if (currentQuery == '' || currentQuery.replace(' ', '') == ''){
      $('#omnisearch-results-activities').remove();
      $results.hide();
      return false;
    } else {
      query = currentQuery;
    }
    
    omniSearch.filterDisplay(query, true);

    if (omniSearch.queries.indexOf(query) > -1) {
      var visible = $('li.omnisearch-result:visible');
      if (visible.length == 0)
        $loading.html('No results found for "'+query+'".').show();
      return false;
    } else {
      $loading.html('Searching "'+query+'"...').show();
      $results.append($loading);
      $wrapper.append($results);
      omniSearch.delaySearch(query);
    }
    
  });
  
  $('li.omnisearch-result').live('mouseover', function() {
    $('li.omnisearch-result').removeClass('selected');
    $(this).addClass('selected');
  });
  
  $('li.omnisearch-result').live('click', function() {
    var goTo = $(this).children('a').first().attr('href');
    window.location = goTo;
  });
  
});
