import PropTypes from 'prop-types';
import React, { Component } from 'react'
import { graphql } from 'react-apollo';
import gql from 'graphql-tag';
import { compose } from 'react-apollo';
import { hasError } from 'apollo-client/core/ObservableQuery';
import { assignFullCalendarStyle } from '../../../libs/fullcalendar-utils';

// import forms from './forms';

class RouteCalendar extends Component {

  static propTypes = {
    eventSources: PropTypes.string.isRequired,
  };

  /**
   * @param props - Comes from your rails view.
   */
  constructor(props) {
    super(props);
    this.state = {
      // Need to construct eventSources here from raw route data retrieved and stored in Apollo XXX
      eventSources: this.props.eventSources,

      // Convert these cookies into state variables that get saved locally, forget the cookies
      // Exhisting Cookies that need to also become state variables:
      // last_calendar_type
      // last_calendar_zoom_level
      // last_viewing_moment
      // last_working_date
      lastRouteIdEdited: -1, // was a session var, not reimplemented yet
      lastCalendarType: 'blah',
      lastCalendarZoomLevel: '00:10:00',
      lastViewingMoment: "some date",
      lastWorkingDate: "some date2",
      calendarAllDayMode: "missing", // changes here will initiate a construction of all-day events that represent missingpeople, when in agendaWeek
    };
  }

  render() {
    const { loading, error } = this.props.data;

    if (loading) {
      return <p>Loading...</p>;
    } else if (error) {
      return <p>Error!</p>;
    }
    return (
      <div>
        <div className='calendar'>
        </div>
        <div id="event_desc_dialog" className="dialog" style={{ display: 'none' }}></div>
        <div id="create_event_dialog" className="dialog" style={{ display: 'none' }}></div>
      </div>
    );
  }

  // componentDidMount() {
  // }

  componentDidUpdate() {
    var top = this;
    // fcEventSources is the massaged data that fcCalendar wants.  
    // Should do that tranformation here on the client vs the server, maybe via an ApolloLink method
    const eventSources = this.props.eventSources; // Take data from props passed in from rails
    // const { fcEventSources } = this.props.data;  // Take data from ApolloClient data requested client side via query, leaarn how to merge these XXX

    this.updateEvents(eventSources, top); // pass self so I can use Setstate and access mutations
  }

  updateEvents = function (eventSources, top) {

    // So fullcalendar callbacks can see
    const { resizeFcEventMutation, 
            moveFcEventMutation, 
            deleteFcEventMutation, 
            duplicateFcEventMutation 
          } = top.props; 

    var eSources = JSON.parse(eventSources);
    assignFullCalendarStyle('instance', eSources[0]);
    assignFullCalendarStyle('modified_instance', eSources[1]);
    assignFullCalendarStyle('special', eSources[2]);
    assignFullCalendarStyle('template', eSources[3]); // Should attach all_day prop here, as it's only a client view type thing

    var dragging = false;

    function lastViewingMoment() {
      // Originally set within the viewRender callback
      var lastViewingMoment = Cookies.get('last_viewing_moment');
      if (lastViewingMoment === undefined) {
        // lastViewingMoment = moment.utc(lastViewingMoment);
        lastViewingMoment = moment.utc(); // today
      } else {
        lastViewingMoment = moment(decodeURIComponent(lastViewingMoment));
      }
      return lastViewingMoment;
    }

    function lastCalendarType() {
      var lastCalendarType = Cookies.get('last_calendar_type');
      if (lastCalendarType === undefined) {
        lastCalendarType = 'agendaWeek';
      }
      return lastCalendarType;
    }

    function lastCalendarZoomLevel() {
      var lastCalendarZoomLevel = Cookies.get('last_calendar_zoom_level');
      if (lastCalendarZoomLevel === undefined) {
        lastCalendarZoomLevel = '00:10:00';
      }
      return lastCalendarZoomLevel;
    }

    // Not used
    // function lastWorkingDate() {
    //   var lastWorkingDate = Cookies.get('last_working_date');
    //   return moment(decodeURIComponent(lastWorkingDate));
    // }

    var loadingFullcalendar = (isLoading, view) => {

      // var spinner;// = createSpinner()

      if (isLoading == true) {
        // spinner = createSpinner()
        // spinner = new Spinner(spinnerOpts).spin(calendarElement);
      } else {
        // spinner.stop();
      }
    };

    var selectFullcalendar = (startDate, endDate, jsEvent, view) => { 

      switch (view.name) {
        case 'month':
          // Move the calendar to the date and put into week mode
          $('.calendar').fullCalendar('gotoDate', startDate);
          $('.calendar').fullCalendar('changeView', 'agendaWeek');
          break;
        default:
          if (startDate.hasTime()) { // did not click within allday area (template)
            var start = new moment(startDate, "s");
            var end = new moment(endDate, "s");
            var slotInterval = new moment.duration("00:10:00"); //, "HH:mm:ss");

            if (end.isSame(start.clone().add(slotInterval))) {
              slotInterval.add(slotInterval);
              end = start.add(slotInterval)
            }

            FullcalendarEngine.Form.display({
              starttime: new Date(startDate),
              endtime: end,
              allDay: startDate.hasTime()
            });
          } else {
            // do something like create a template? not really necessary as they should define a special first
          }
      }
    }

    var eventClickFullcalendar = (event, jsEvent, view) => {
      // alert(jsEvent.which);
      if (event.category == "template") { //&& event.child_id exhists?
        var class_child_id = '.instance-' + event.child_id;
        $('.fc-scroller').scrollTo(class_child_id, 1, function () {
          $(class_child_id).effect("highlight", { color: "white" }, 300);
        });
      }
      if ((event.category != "template") && (event.id > -1)) {
        FullcalendarEngine.displayEditScreen(event.id);
      }
    }

    var customButtonsHash = {
      button_5: {
        text: '5',
        click: function () {
          setZoomLevel('00:05:00');
        }
      },
      button_10: {
        text: '10',
        click: function () {
          setZoomLevel('00:10:00');
        }
      },
      button_30: {
        text: '30',
        click: function () {
          setZoomLevel('00:30:00');
        }
      },
      button_verify: {
        text: 'missing',
        click: function () {
          Cookies.set('calendar_all_day_mode', 'missing_persons');
          top.setState({ calendarAllDayMode: 'missing_persons' });
          $('.calendar').fullCalendar('option', 'allDayText', " Missing:");
          var startDateToDisplay = lastViewingMoment().format();
          removeAllDayEvents();
          showMissingPassengers(startDateToDisplay, top); // How to define callback here
        }
      },
      button_template: {
        text: 'routines',
        click: function () {
          Cookies.set('calendar_all_day_mode', 'template');
          top.setState({ calendarAllDayMode: 'template' });
          $('.calendar').fullCalendar('option', 'allDayText', "Routines");
          var startDateToDisplay = lastViewingMoment().format();
          removeAllDayEvents();
          addAllDayEvents(eSources[3]);
        }
      },
    };

    function setZoomLevel(zoomLevel) {
      Cookies.set('last_calendar_zoom_level', zoomLevel);
      top.setState({ lastCalendarZoomLevel: zoomLevel });
      $('.calendar').fullCalendar('option', 'slotDuration', zoomLevel);
      // http://fullcalendar.io/docs/utilities/Duration/ Add this in !!!
      // full_calendar_options.slotLabelInterval = moment({ minutes:30 })
    }

    // full_calendar_options.dayClick =  function(event, jsEvent, view) {
    //   alert("dayClick hi");
    //   if (view.name == 'month') {
    //     // alert("dayClick");
    //     // $('.calencar').fullCalendar( 'gotoDate', event.start );
    //     $(".calendar").fullCalendar( 'changeView', 'agendaWeek' );
    //     // Not sure how to stop the new event creation screen from month view.
    //     // jsEvent.stopImmediatePropagation();
    //     // jsEvent.stopPropagation();
    //     // return true;
    //   };
    // };

    $('.calendar').fullCalendar({
      // Based on Cookies ____
      defaultView: lastCalendarType(),
      defaultDate: lastViewingMoment(),
      slotDuration: lastCalendarZoomLevel(),
      header: {
        left: 'prev,next today button_5, button_10, button_30, button_verify, button_template',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      weekends: false,
      height: 800,
      minTime: "06:30:00",
      maxTime: "23:00:00",
      timezone: "local",
      displayEventEnd: false,
      allDaySlot: true,
      allDayText: "Routines",
      slotEventOverlap: false,
      editable: true,
      displayEventTime: false,
      // events: "",// Need to mute this because somewhere within the fc engine, it's setting it
      eventSources: eSources,
      loading: loadingFullcalendar,
      eventRender: function (event, element) {

        element.find('.fc-title').append("<br/>" + event.description);

        // Inject stuff for dynamic context-menu options
        element.attr('data-route-category', event.category);
        element.attr('data-has-children', event.has_children);  // added from server to help ui
        element.attr('data-child-id', event.child_id);         
        element.attr('data-event-id', event.id);
        element.addClass('route-' + event.id);                  // make easier to use scrollTo

        element.addTouch();

        if (event.category.indexOf("instance") > -1) {
          element.addClass('instance-' + event.id); // so we can scrollTo when the template is clicked
        }

        // if (event.isPending) {
        //   element.addClass('pending'); // so we can show it's network update status this way?
        // }

        element.addClass('context-class'); // For jquery contextMenu, so we can right-click and delete, etc


        // XXX template events will not display in fullcalendar > 3.4 because they have end times set, it's a bug I hope..

        if (event.category == "template") {

          // XXX Reimplement once lastRouteIdEdited get's reattached
          // if ((event.category == "template") && (event.id == last_route_id_edited)) {
          //   element.addClass('CurrentEvent'); // Do it here now instead of at server, makes sense..
          // }

          if (!event.has_children) {
            element.css({ "background-color": "white" });
            element.css({ "border-color": "green" });
            // element.addClass('ui-icon-arrowreturn-1-s');
          }

          if (currentViewName === 'month') {
            element.hide();
          }

        } 

        // if (!dragging) {
        //   // Use something like this if I remove the scroll thing and just force
        //   //  fullcalendar to stretch without a scroll !!!
        //   // $(window).scrollTo('.CurrentEvent',1, function() {
        //   //   $('.CurrentEvent').effect( "highlight", {color:"white"}, 300 );
        //   // });
        //   // $('.fc-scroller').scrollTo('.CurrentEvent',1, function() {
        //   //   $('.CurrentEvent').effect( "highlight", {color:"white"}, 300 );
        //   // });
        // };
      },
      customButtons: customButtonsHash,
      eventDragStart: eventDragStartFullcalendar,
      eventDragEnd: eventDragEndFullcalendar,
      eventDrop: eventDropFullcalendar,
      eventResizeStart: eventResizeStartFullcalendar,
      eventResizeEnd: eventResizeEndFullcalendar,
      eventAfterAllRender: eventAfterAllRenderFullcalendar,
      eventResize: eventResizeFullcalendar,
      eventClick: eventClickFullcalendar,
      viewRender: viewRenderFullcalendar,
      selectable: true,
      select: selectFullcalendar,
    });

    var eventDragStartFullcalendar = (event, jsEvent, ui, view) => {
      dragging = true;
    };

    var eventResizeStartFullcalendar = (event, jsEvent, ui, view) => {
      dragging = true;
    };

    var eventDragEndFullcalendar = (event, jsEvent, ui, view) => {
      dragging = false;
    };

    var eventResizeEndFullcalendar = (event, jsEvent, ui, view) => {
      dragging = false;
    };
    
    var currentViewName;
    function viewRenderFullcalendar(view, element) {

      currentViewName = view.name;

      Cookies.set('last_calendar_type', view.name);
      // self.setState({ lastCalendarType: view.name }); // changin state is mucking up fc

      var viewingMoment = $.fullCalendar.moment.utc(view.intervalStart)
      Cookies.set('last_viewing_moment', viewingMoment.format());
      // top.setState({ lastViewingMoment: viewingMoment.format() });

      if (view.name == "month") {
        $('.fc-button_5-button').hide();
        $('.fc-button_10-button').hide();
        $('.fc-button_30-button').hide();
        $('.fc-button_verify-button').hide();
        $('.fc-button_template-button').hide();
      }
      else {
        $('.fc-button_5-button').show();
        $('.fc-button_10-button').show();
        $('.fc-button_30-button').show();

        var calendarAllDayMode = Cookies.get('calendar_all_day_mode');
        if (calendarAllDayMode == 'missing_persons') {
          $('.fc-button_verify-button').hide();
          $('.fc-button_template-button').show();
        }
        else {
          $('.fc-button_verify-button').show();
          $('.fc-button_template-button').hide();
        }
      }
    };

    // Not really needed now that things are being updated clientside without fc reload taking place?
    var eventAfterAllRenderFullcalendar = (view) => {

      // if(view.name === "agendaWeek" || view.name === "agendaDay"){
      $('.fc-scroller').scrollTo('.CurrentEvent', 1, function () {
        $('.CurrentEvent').effect("highlight", { color: "white" }, 300);
      });
      // };
      // $('.fc-today').siblings().addClass('week-highlight');
    };

    function eventResizeFullcalendar(event, delta, revertFunc) {
      var spinner = createSpinner();

      resizeFcEventMutation({
        variables: {
          routeId: event.id,
          end_time: event.end.format()
        }
      })
        .then(({ data }) => {
          var updatedEvent = JSON.parse(data.resizeFcEventMutation);
          // console.log(updatedEvent);
          $('.calendar').fullCalendar( 'removeEvents', [Number.parseInt(event.id)] )
          assignFullCalendarStyle(updatedEvent.category, updatedEvent);
          $('.calendar').fullCalendar('renderEvent', updatedEvent);
          spinner.stop();

        }).catch((error) => {
          spinner.stop();
          console.log('there was an error sending the query', error);
        });
    }

    function eventDropFullcalendar(event, delta, revertFunc, jsEvent, ui, view) {
      var spinner = createSpinner();

      moveFcEventMutation({
        variables: {
          routeId: event.id,
          start_time: event.start.format(),
          end_time: event.end.format()
        }
      })
        .then(({ data }) => {

          var updatedEvent = JSON.parse(data.moveFcEventMutation);

          $('.calendar').fullCalendar( 'removeEvents', [Number.parseInt(event.id)] )
          assignFullCalendarStyle(updatedEvent.category, updatedEvent);
          $('.calendar').fullCalendar('renderEvent', updatedEvent);

          if ((updatedEvent.category == "special") && ((event.category == "instance") || (event.category == "modified_instance"))) {
            // update the template to show it has no instances
            var templateId = $(`[data-child-id='${event.id}']`).first().attr('data-event-id');
            var templatefcEvent = $('.calendar').fullCalendar( 'clientEvents', templateId.toString())[0];
            templatefcEvent.has_children = false;
            templatefcEvent.child_id = '';
            assignFullCalendarStyle("template", templatefcEvent)
            $('.calendar').fullCalendar( 'updateEvent', templatefcEvent); 
          }
          spinner.stop();

        }).catch((error) => {
          spinner.stop();
          console.log('there was an error sending the query', error);
        });
    }

    $.extend($.scrollTo.defaults, {
      axis: 'y',
      duration: 800,
      over: { left: 0.5, top: -1 },
      interrupt: true
    });

    $('.calendar').addClass('noselect');
    $('.calendar').fullCalendar('gotoDate', lastViewingMoment());

    // http://swisnl.github.io/jQuery-contextMenu/
    $.contextMenu({
      selector: '.context-class',
      position: function (opt, x, y) { opt.$menu.position({ my: "center top", at: "center bottom", of: this }) },
      build: function ($trigger, e) {
        // this callback is executed every time the menu is to be shown
        // its results are destroyed every time the menu is hidden
        // e is the original contextmenu event, containing e.pageX and e.pageY (amongst other data)
        // https://swisnl.github.io/jQuery-contextMenu/demo/dynamic-create.html
        return {

          callback: function (key, options) {

            var eventId = $trigger.data('event-id'); // grabe the route id instead and ensure that's OK everywhere...makesure routeid is planted in markup
            var routeId = $trigger.data('route-id');  // use this !!! XXX

            switch (key) {
              case "delete": {
                deleteFcEvent(eventId, deleteFcEventMutation, top, $trigger);
                break;
              }
              case "make_template": {
                duplicateFcEvent(eventId, 'template', top, $trigger);
                break;
              }
              case "make_instance": {
                duplicateFcEvent(eventId, 'instance', top, $trigger);
                break;
              }
              case "make_special": {
                duplicateFcEvent(eventId, 'special', top, $trigger);
                break;
              }
              case "edit": {
                FullcalendarEngine.displayEditScreen(eventId);
                break;
              }
              case "revert_to_template": {
                revertToTemplate(eventId, top, $trigger);
                break;
              }
              
              default: {
                // FullcalendarEngine.Events[key](eventId); // Think that's it now, just take out
                break;
              }
            }
          },
          items: $(e.currentTarget).determineEventItems()
        };
      }
    });

    jQuery.fn.extend({
      determineEventItems: function () {

        var category = $(this).data("routeCategory");
        var hasChildren = $(this).data("hasChildren");
        var eventItems = {}

        switch (category) {

          case 'template':
            if (hasChildren)
              eventItems = {
                // "edit": {name: "Edit", icon: "edit"}, // caused "undefined method `reject' for false:FalseClass"
                "delete": { name: "Delete", icon: "delete" },
                // "reset_instance_event": {name: "Overwrite Instance", icon: "paste"},

              }
            else
              eventItems = {
                // "edit": {name: "Edit", icon: "edit"}, // caused "undefined method `reject' for false:FalseClass"
                "delete": { name: "Delete", icon: "delete" },
                "make_instance": { name: "Create Instance", icon: "copy" },
              }
            break;

          case 'instance':
            // $event_actions.append($edit_event).append(" | ").append($delete_event).append(" | ").append($make_special_event)
            eventItems = {
              "edit": { name: "Edit", icon: "edit" },
              "delete": { name: "Delete", icon: "delete" },
              "make_special": { name: "Duplicate", icon: "copy" },
            }
            break;

          case 'modified_instance':
            // $event_actions.append($edit_event).append(" | ").append($delete_event).append(" | ").append($revert_to_template_event).append(" | ").append($make_special_event)
            eventItems = {
              "edit": { name: "Edit", icon: "edit" },
              "delete": { name: "Delete", icon: "delete" },
              "revert_to_template": { name: "Revert", icon: "paste" },
              "make_special": { name: "Duplicate", icon: "copy" },
            }
            break;

          case 'special':
            // $event_actions.append($edit_event).append(" | ").append($delete_event).append(" | ").append($make_template_event).append(" | ").append($make_special_event)
            eventItems = {
              "edit": { name: "Edit", icon: "edit" },
              "delete": { name: "Delete", icon: "delete" },
              "make_template": { name: "Create Template", icon: "copy" },
              "make_special": { name: "Duplicate", icon: "copy" },
            }
            break;

          default:
        }
        return eventItems;
      }
    });

  };

}

var spinnerOpts = {
  lines: 8 // The number of lines to draw
  , length: 17 // The length of each line
  , width: 5 // The line thickness
  , radius: 23 // The radius of the inner circle
  , scale: 0.25 // Scales overall size of the spinner
  , corners: 1 // Corner roundness (0..1)
  , color: '#000' // #rgb or #rrggbb or array of colors
  , opacity: 0.05 // Opacity of the lines
  , rotate: 0 // The rotation offset
  , direction: 1 // 1: clockwise, -1: counterclockwise
  , speed: 0.9 // Rounds per second
  , trail: 48 // Afterglow percentage
  , fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
  , zIndex: 2e9 // The z-index (defaults to 2000000000)
  , className: 'spinner' // The CSS class to assign to the spinner
  , top: '50%' // Top position relative to parent
  , left: '50%' // Left position relative to parent
  , shadow: true // Whether to render a shadow
  , hwaccel: false // Whether to use hardware acceleration
  , position: 'absolute' // Element positioning
}

function createSpinner(attachElement = document.getElementsByClassName("calendar")[0]) {
      
  var opts = spinnerOpts;
  opts['scale'] = .50;
  opts['top'] = '50%';
  opts['left'] = '50%';
  var spinner = new Spinner(opts).spin(attachElement);
  return spinner;
}

// READ XXX
// https://notes.devlabs.bg/how-to-use-jquery-libraries-in-the-react-ecosystem-7dfeb1aafde0
// https://swisnl.github.io/jQuery-contextMenu/demo/dynamic-create.html
function deleteFcEvent(routeId, deleteFcEventMutation, top, $trigger) { 

  var spinner = createSpinner($trigger.get(0));
  var origEvent = $('.calendar').fullCalendar( 'clientEvents', routeId.toString())[0];

  top.props.deleteFcEventMutation({
    variables: {
      routeId: routeId
    }
  })
    .then(({ data }) => {

      if ((origEvent.category === "template") && (origEvent.has_children)) {
        console.log(origEvent);
        var childInstance = $('.calendar').fullCalendar( 'clientEvents', origEvent.child_id.toString())[0];
        // The template's instances are now "special" so needs to be updated to show that visually
        childInstance.category = "special";  // Should not do this redundant logic, will go away once I hook up apollo-client to entities
        assignFullCalendarStyle("special", childInstance);
        $('.calendar').fullCalendar( 'updateEvent', childInstance );
      }

      if ((origEvent.category === "instance") || (origEvent.category === "modified_instance")) {
        
        // Need reference to parent
        // var templatefcEvent = resetTemplateViaChildId(routeId, ); XXX, actually wrap all the following stuff into this
        var templateId = $(`[data-child-id='${routeId}']`).first().attr('data-event-id');
        var templatefcEvent = $('.calendar').fullCalendar( 'clientEvents', templateId.toString())[0];
        
        // The template's instances now have no children so need to be updated to show that visually, should probably have a new category for template_fulfilled or ...
        templatefcEvent.has_children = false; 
        templatefcEvent.child_id = ''; 
        $('.calendar').fullCalendar( 'updateEvent', templatefcEvent); // The event will color correctly during render, should just set it here if I can..
      }

      // Remove event representation
      $('.calendar').fullCalendar('removeEvents', [Number.parseInt(data.deleteFcEventMutation.id)]);
      spinner.stop();

    }).catch((error) => {
      spinner.stop();
      console.log('there was an error sending the query', error);
    });
};

// for making duplicating routes as templates, instances, and special
function duplicateFcEvent(routeId, category, top, $trigger) {
  var spinner = createSpinner($trigger.get(0))
  var origEvent = $('.calendar').fullCalendar( 'clientEvents', routeId.toString())[0];

  top.props.duplicateFcEventMutation({
    variables: {
      routeId: routeId,
      category: category
    }
  })
    .then(({ data }) => {
      var newEvent = data.duplicateFcEventMutation;
      newEvent = JSON.parse(newEvent);
      
      if (category === "template") { // creating new template
        newEvent.has_children = true;
        newEvent.child_id = origEvent.id;
        origEvent.category = "instance";  // Should not do this redundant logic, will go away once I hook up apollo-client to entities
        assignFullCalendarStyle("instance",origEvent);
      }
      if (category === "instance") { // creating new instance (original is/was template)
        // The original was an instance so needs to be updated visually to show it has_children
        origEvent.has_children = true;
        origEvent.child_id = newEvent.id;
      }
      assignFullCalendarStyle(category, newEvent);
      $('.calendar').fullCalendar('renderEvent', newEvent);
      $('.calendar').fullCalendar( 'updateEvent', origEvent );

      spinner.stop();

    }).catch((error) => {
      spinner.stop();
      console.log('there was an error sending the query', error);
    });
};

function revertToTemplate(eventId, top, $trigger) {
  var spinner = createSpinner($trigger.get(0))
  var clickedEvent = $('.calendar').fullCalendar( 'clientEvents', eventId.toString())[0];

  top.props.revertToTemplateMutation({
    variables: {
      eventId: eventId
    }
  })
    .then(({ data }) => {
      var newRevertedRoute = JSON.parse(data.revertToTemplateMutation);
      assignFullCalendarStyle("instance",newRevertedRoute);
      $('.calendar').fullCalendar('removeEvents', [Number.parseInt(clickedEvent.id)]);
      $('.calendar').fullCalendar('renderEvent', newRevertedRoute); // Same ID?

      var templateId = $(`[data-child-id='${eventId}']`).first().attr('data-event-id');
      var templatefcEvent = $('.calendar').fullCalendar( 'clientEvents', templateId.toString())[0];

      templatefcEvent.has_children = true; 
      templatefcEvent.child_id = newRevertedRoute.id; // Event/route id same ?? make sure..
      // assignFullCalendarStyle("template_implemented",newRevertedRoute); // wishful thinking
      $('.calendar').fullCalendar( 'updateEvent', templatefcEvent); // The event will color correctly during render, should just set it here if I can..
      spinner.stop();

    }).catch((error) => {
      spinner.stop();
      console.log('there was an error sending the query', error);
    });
};

function removeAllDayEvents() {
  $('.calendar').fullCalendar('removeEvents',  function(evt) {return evt.allDay == true;});
  // $('.calendar').fullCalendar('removeEventSource',  allDayEvents);
  // Not sure if these empty eventSources could pileup, from fullcalendar perspective? 
  // I'm adding via addEventSource, taking away via removeEvents 
}

function addAllDayEvents(allDayEvents) {
  // $('.calendar').fullCalendar('renderEvents',  allDayEvents.events);
  // Above way will bypass eventRender, where I'm changing color of templates if they have kids, so no..
  $('.calendar').fullCalendar('addEventSource',  allDayEvents);
}

function showMissingPassengers(start, top) {

  var dayRowElement = document.getElementsByClassName("fc-content-skeleton")[0];
  var spinner = new Spinner(spinnerOpts).spin(dayRowElement);

  top.props.missingPassengersQuery.refetch({
    startDate: start
  })
    .then(({ data }) => {
      spinner.stop();
      var missingPassengersEvents = { events: JSON.parse(data.missingPassengers) };
      addAllDayEvents(missingPassengersEvents) // could replace with this..to help modularize jquery stuff
      // $('.calendar').fullCalendar('addEventSource', missingPassengersEvents);

    }).catch((error) => {
      spinner.stop();
      console.log('there was an error sending the query', error);
    });
}

// ________________________________ QUERIES ____________________________________________

const fcEventSourcesRoutesQuery = gql`
  query fcEventSourcesRoutesQuery {
    fcEventSourcesRoutes 
  }
`;

const MISSING_PASSENGERS_QUERY = gql`
  query missingPassengersQuery ($startDate: String!){
    missingPassengers(startDate: $startDate)
  }
`;

// ________________________________ Mutations ____________________________________________

const resizeFcEventMutation = gql`
  mutation resizeFcEventMutation($routeId: Int!, $end_time: String!) {
    resizeFcEventMutation(routeId: $routeId, end_time: $end_time)
  }
`;

const moveFcEventMutation = gql`
  mutation moveFcEventMutation($routeId: Int!, $start_time: String!, $end_time: String!) {
    moveFcEventMutation(routeId: $routeId, start_time: $start_time, end_time: $end_time) 
  }
`;

const deleteFcEventMutation = gql`
  mutation deleteFcEventMutation($routeId: Int!) {
    deleteFcEventMutation(routeId: $routeId) {id}
  }
`;

const duplicateFcEventMutation = gql`
  mutation duplicateFcEventMutation($routeId: Int!, $category: String!) {
    duplicateFcEventMutation(routeId: $routeId, category: $category) 
  }
`;

const revertToTemplateMutation = gql`
  mutation revertToTemplateMutation($eventId: Int!) {
    revertToTemplateMutation(eventId: $eventId) 
  }
`;

// ________________________________ Compose ____________________________________________

export default compose(
  graphql(resizeFcEventMutation, { name: 'resizeFcEventMutation' }),
  graphql(moveFcEventMutation, { name: 'moveFcEventMutation' }),
  graphql(deleteFcEventMutation, { name: 'deleteFcEventMutation' }),
  graphql(duplicateFcEventMutation, { name: 'duplicateFcEventMutation' }),
  graphql(revertToTemplateMutation, { name: 'revertToTemplateMutation' }),
  // graphql(createFcEventMutation, { name: 'createFcEventMutation' }),

  graphql(fcEventSourcesRoutesQuery, { 
    name: 'data' 
  }),
  graphql(MISSING_PASSENGERS_QUERY, {
    name: 'missingPassengersQuery',
    options: {
      variables: { startDate: "" },
      skip: false
    }
  }),

)(RouteCalendar);
// Why I (have to ?) declare variables for query above, but not for mutations??

// https://www.apollographql.com/docs/react/basics/queries.html