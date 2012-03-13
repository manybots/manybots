$(function() {
  var calendar = $('#fullcalendar').fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,basicWeek,basicDay'
    },
    slotMinutes: 60,
    loading: function(bool) {
      if (bool) {
        $('#loading').show();
      } else { 
        $('#loading').hide();
      }
    },
    events: window.location.pathname + ".js" + window.location.search,
    eventRender: function(event, element) {
      element.qtip({
        content: {
          text: "Loading activity details... please wait.",
          url: event.description
        },
        hide: {
          fixed: true // Make it fixed so it can be hovered over
        },
        position: {
          corner: {
             target: 'topLeft',
             tooltip: 'bottomLeft'
          }
        },
      });
    }
  });
});

