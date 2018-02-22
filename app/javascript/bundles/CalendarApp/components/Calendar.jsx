import PropTypes from 'prop-types';
import React, { Component } from 'react'
import { graphql } from 'react-apollo';
import gql from 'graphql-tag';
import { assignFullCalendarStyle } from '../../../libs/fullcalendar-utils';

class Calendar extends Component {
  static propTypes = {
    eventSources: PropTypes.string.isRequired,
  };

  /**
   * @param props - Comes from your rails view.
   */
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div>
        <div className='calendar'></div>
      </div>
    );
  }
  componentDidMount() {
    // eventSources is the massaged data that fcCalendar wants.  
    this.updateEventSources(JSON.parse(this.props.eventSources));
  }

  updateEventSources = (eventSources) => {

    var eSources = eventSources;

    $('.calendar').fullCalendar('destroy');

    assignFullCalendarStyle('instance', eSources[0]);
    assignFullCalendarStyle('modified_instance', eSources[1]);
    assignFullCalendarStyle('special', eSources[2]);
    
    $('.calendar').fullCalendar({
      weekends: false,
      allDaySlot: false,
      defaultView: "month",
      selectable: false,
      editable: false,
      slotDuration: '00:10:00',
      scrollTime: '07:00:00',
      height: 'auto',
      // width: 400,
      minTime: "06:30:00",
      maxTime: "23:00:00",
      timezone: "local",
      displayEventEnd: false,
      displayEventTime: false,
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      eventSources: eSources,
      contentHeight: 'auto',
    });

  };

}

export default Calendar;