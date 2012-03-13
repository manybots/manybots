var Prediction = {
  current: [],
  wrapper: null
};

Prediction = {
  list : null,
  fetchAll : function(url, targetElement, callback) {
    var notifs = $.get(''+url+'.json', function(data) {
      var items = data.data.items;
      Prediction.current = items;
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
    Prediction.fetchAll(url, targetElement, Prediction.drawAll);
  },  
  fetch: function(url, container, callback) {
    $.get(''+url+'.json', function(data) {
      Prediction.current =  [data];
      Prediction.draw(data, container, container);
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
    Prediction.fetch(id, container, exotic);
  },
  drawAll: function(predictions, targetElement) {
    var $source = targetElement;
    for (var i = predictions.length - 1; i >= 0; i--){
      var $this = $source.clone();
      $this.attr('id', i);
      var $notif = Prediction.draw(predictions[i], $this, $source);
    }
  },
  draw: function(prediction, container, target) {
    var $this = $(container);
    var $prediction = $this.children('.box-content').children('.notification-wrapper');
    var $avatar = $prediction.children('.avatar');
    var $content = $prediction.children('.notification');
    
    $avatar.children('img.avatar').attr('src', prediction.actor.image.url);
    $content.children('.title').html(prediction.title);
    $content.children('p.via').children('span.generator.name').
        html('<a href="'+prediction.provider.url+'">'+prediction.provider.displayName+'</a>');
    if (prediction.provider.image)
      $content.children('p.via').children('img.generator.image').attr('src', prediction.provider.image.url);
    $content.children('p.via').children('span.published').
      html('<a href="'+prediction.id+'" title="'+prediction.published+'">'+prettyDate(prediction.published)+'</a>');
    
    var tagList = prediction.tags;
    for (var i = tagList.length - 1; i >= 0; i--){
      var $tagSpan = $('<a />').addClass('activity tag').text(tagList[i]);
      $content.children('.tags').append($tagSpan);
    };
    if (Prediction.wrapper) {
      $(Prediction.wrapper).prepend($this);
    } else {
      $('.main-content').prepend($this);
    }
    $this.show();    
  },
  drawExotic: function(prediction, target) {
    if (prediction.target.position)
      Prediction.drawPlace(prediction.target.position, target);
    else if (prediction.object.position)
      Prediction.drawPlace(prediction.object.position, target);
      
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

