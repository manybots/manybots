var baseUrl = '';

var ManybotsClient = function(config) {
  if(!config) config = {};
  config.host = config.host || 'www.manybots.com';
  config.protocol = config.protocol || 'https';
  var manybotsUrl = config.protocol + '://'+ config.host;
  baseUrl = manybotsUrl;
  var message = 'Please enter your API key from '+ manybotsUrl + '/account';
  var manybotsClient = {};
  
  function needsApiKey() {
    if(window.location.protocol === 'file:' && baseUrl === '') {
      var apiKey = getApiKey();
      if(!apiKey) apiKey = setApiKey(prompt(message, ''));
      baseUrl = manybotsUrl;
    }
  }

  function setApiKey(apiKey) {
    sessionStorage.setItem("mb_apiKey_" + config.host, apiKey);
    return apiKey;
  }
  
  function resetApiKey() {
    apiKey = null;
    sessionStorage.setItem("mb_apiKey_" + config.host, null);
    return apiKey;
  }

  function getApiKey() {
    var apiKey = sessionStorage.getItem("mb_apiKey_" + config.host);
    // things get converted to strings in some browsers, so check those, just to be safe
    if(apiKey == 'null') return null;
    if(apiKey == 'undefined') return undefined;
    return apiKey;
  }

  manybotsClient.getJSON = function(path, params, callback, retry) {
    if (getApiKey())
      params.auth_token = getApiKey();

    if(path.indexOf('/') !== 0) path = '/' + path ;
    if(!callback && typeof params === 'function') {
      callback = params;
      params = {};
    }
    
    $.ajax({
      url: baseUrl + path + '.json',
      data: params,
      dataType: "jsonp",
      type: "GET",
      // processData: false,
      contentType: "application/json",
      success: function(data, success) {
        callback(data, success);
      } 
    });
    
    
    // $.getJSON(baseUrl + path + '.json', params, function(data, success) {
    //   callback(data, success);
    // });
  }
  
  needsApiKey();
  return manybotsClient;
}

var ManybotsItem = function(item) {
  if(!item) return false;
  
  var activityObject = {};
  
  activityObject.raw = item;
  
  activityObject.toHTML = function(acti) {
    var activity = activityObject.raw;
    
    var $wrapper = $('<div />');
    $wrapper.addClass('manybots-item')
    $wrapper.attr('id', activity.id.split('/')[-1]);
    var $avatarBox = $('<div />').addClass('avatar');
    var $avatar = $('<img/>').attr('src', activity.actor.image.url).attr('width', '40').attr('height', '40');
    $avatarBox.prepend($avatar);
    
    var $contentBox =  $('<div />').addClass('content');
    var $title =  $('<div />').addClass('title').html(activity.title);
    $contentBox.prepend($title);
    var $via =  $('<p />').addClass('via').html('via ');
    $contentBox.append($via);
    
    var $generator = $('<span />').addClass('generator name').html(
      '<a href="'+activity.provider.url+'">'+activity.provider.displayName+'</a>, '
    );
    if (activity.provider.image) {
      var $generatorIcon = $('<span />').addClass('generator image');
      var $generatorImg = $('<img />').attr('src', activity.provider.image.url).attr('width', '12').attr('height', '12');
      $generatorIcon.append($generatorImg);
      $generator.prepend($generatorIcon);
    }
    
    $via.append($generator);
    
    var $published = $('<span />').addClass('published').html(
      '<a href="'+activity.id+'" title="'+activity.published+'">'+prettyDate(activity.published)+'</a>'
    );
    $via.append($published);
    
    var $tags = $('<div />').addClass('tags').html(activity.tags.join(', '));
    $contentBox.append($tags);
    
    $wrapper.prepend($avatarBox);
    $wrapper.append($contentBox);
    
    return $wrapper;
  };
  
  /*
   * JavaScript Pretty Date
   * Copyright (c) 2011 John Resig (ejohn.org)
   * Licensed under the MIT and GPL licenses.
   */

  // Takes an ISO time and returns a string representing how
  // long ago the date represents.
  function prettyDate(time){
  	var date = new Date((time || "").replace(/-/g,"/").replace(/[TZ]/g," ")),
  		diff = (((new Date()).getTime() - date.getTime()) / 1000),
  		day_diff = Math.floor(diff / 86400);

  	if ( isNaN(day_diff) || day_diff < 0 )
  		return;

  	return day_diff == 0 && (
  			diff < 60 && "just now" ||
  			diff < 120 && "1 minute ago" ||
  			diff < 3600 && Math.floor( diff / 60 ) + " minutes ago" ||
  			diff < 7200 && "1 hour ago" ||
  			diff < 86400 && Math.floor( diff / 3600 ) + " hours ago") ||
  		day_diff == 1 && "Yesterday" ||
  		day_diff < 7 && day_diff + " days ago" ||
  		day_diff < 31 && Math.ceil( day_diff / 7 ) + " weeks ago" ||
  		day_diff < 360 && Math.ceil( day_diff / 31 ) + " months ago" ||
  		day_diff >= 365 && Math.ceil( day_diff / 365 ) + " years ago"
  		; 
  };

  // If jQuery is included in the page, adds a jQuery plugin to handle it as well
  if ( typeof jQuery != "undefined" ) {
  	jQuery.fn.prettyDate = function(){
  		return this.each(function(){
  			var date = prettyDate(this.title);
  			if ( date )
  				jQuery(this).text( date );
  		});
  	};
  };
   
  return activityObject;
}