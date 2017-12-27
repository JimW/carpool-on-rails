import PropTypes from 'prop-types';
import React from 'react';
import apolloClient from 'lib/apolloClient';
import gql from 'graphql-tag';

export default class Calendar extends React.Component {
  static propTypes = {
    eventSources: PropTypes.string.isRequired, // this is passed from the Rails view
  };

  /**
   * @param props - Comes from your rails view.
   */
  constructor(props) {
    super(props);
    // How to set initial state in ES6 class syntax
    // https://facebook.github.io/react/docs/reusable-components.html#es6-classes
    this.state = { 
      eventSources: this.props.eventSources
     };
  }

  render() {
    return (
      <div>
        <div className='calendar'></div>
      </div>
    );
  }

  componentDidMount() {
    this.updateEventSources(this.state.eventSources) 
  };

  updateEventSources = (eventSources) => {
    
    this.setState({ eventSources });
    var eSources = JSON.parse(eventSources);

    $('.calendar').fullCalendar('destroy');

    // Add in the fullcalendar formatting for each type of route, should centralize this !!! 
    eSources[0].color = '#D4FFD7';
    eSources[0].textColor = '#524B3E';
    eSources[0].borderColor = '#93CC97';
    eSources[1].color = '#F0FFB6';
    eSources[1].textColor = '#35352E';
    eSources[1].borderColor = '#50DA59';
    eSources[2].color = '#F9E0CA';
    eSources[2].textColor = '#503A0D';
    eSources[2].borderColor = '#E4AFAF';

    $('.calendar').fullCalendar({
      weekends: false,
      allDaySlot: false,
      defaultView: "month",
      selectable: false,
      editable: false,
      slotDuration: '00:10:00',
      scrollTime: '07:00:00',
      height: 650,
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