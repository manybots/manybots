var Notification = {
  current: [],
  wrapper: null
};


Notification = {
  list : null,
  fetchAll : function(url, targetElement, callback) {
    var notifs = $.get(''+url+'.json', function(data) {
      var items = data.data.items;
      Notification.current = items;
      if (typeof(callback) == "function") {
        callback(items, targetElement);
      } else if (typeof(callback) == "Array") {
        for (var i = callback.length - 1; i >= 0; i--){
          callback[i](items[0], targetElement);
        };
      };
    });    
  },
  listAll: function(url, targetElement, exotic) {
    Notification.fetchAll(url, targetElement, Notification.drawAll);
  },  
  fetch: function(url, container, callback) {
    $.get(''+url+'.json', function(data) {
      Notification.current =  [data];
      Notification.draw(data, container, container);
      if (typeof(callback) == "function") {
        callback(data, container);
      } else if (typeof(callback) == "Array") {
        for (var i = callback.length - 1; i >= 0; i--){
          callback[i](data, container);
        };
      };
      
    });
  },
  show: function(id, container, exotic) {
    Notification.fetch(id, container, exotic);
  },
  drawAll: function(notifications, targetElement) {
    var $source = targetElement;
    for (var i = notifications.length - 1; i >= 0; i--){
      var $this = $source.clone();
      $this.attr('id', i);
      var $notif = Notification.draw(notifications[i], $this, $source);
    }
  },
  draw: function(notification, container, target) {
    var $this = $(container);
    var $notification = $this.children('.box-content').children('.notification-wrapper');
    var $avatar = $notification.children('.avatar');
    var $content = $notification.children('.notification');
    var $read_function = $notification.children('.actions');
    
    $avatar.children('img.avatar').attr('src', notification.actor.image.url);
    $content.children('.title').html(notification.title);
    $content.children('p.via').children('span.generator.name').
        html('<a href="'+notification.provider.url+'">'+notification.provider.displayName+'</a>');
    if (notification.provider.image)
      $content.children('p.via').children('img.generator.image').attr('src', notification.provider.image.url);
    $content.children('p.via').children('span.published').
      html('<a href="'+notification.id+'" title="'+notification.published+'">'+ (prettyDate(notification.published) || new Date((notification.published).replace(/-/g,"/").replace(/[TZ]/g," ")) ) +'</a>');
    
    var tagList = notification.tags;
    for (var i = tagList.length - 1; i >= 0; i--){
      var $tagSpan = $('<a />').addClass('activity tag').text(tagList[i]);
      $content.children('.tags').append($tagSpan);
    };
    if (Notification.wrapper) {
      $(Notification.wrapper).prepend($this);
    } else {
      $('.main-content').prepend($this);
    }
    $this.show();    
  },
  drawExotic: function(notification, target) {
    if (notification.target.position)
      Notification.drawPlace(notification.target.position, target);
    else if (notification.object.position)
      Notification.drawPlace(notification.object.position, target);
      
    return false;
  },
  drawPlace: function(geo, target) {
    var $target = $('#notification-place-wrapper');
    var $img = $('<img />');
    mapsUrl = 'http://maps.googleapis.com/maps/api/staticmap?center='
    mapsUrl += '' +escape(geo)
    mapsUrl += '&zoom=14&size=400x200&sensor=false&markers=color:red'
    mapsUrl += '' +escape('|label=P|'+geo)
    $img.attr('src', mapsUrl);
    $target.prepend($img);
  }
  
}

