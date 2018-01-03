import PropTypes from 'prop-types';
import React, { Component } from 'react'
import { graphql  } from 'react-apollo';
import gql from 'graphql-tag';

class Calendar extends Component {
  // static propTypes = {
  //   eventSources: PropTypes.string.isRequired, 
  // };

  /**
   * @param props - Comes from your rails view.
   */
  constructor(props) {
    super(props);
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
        <div className='calendar'></div>
      </div>
    );
  }
  componentDidUpdate() {
    const { fcEventSources } = this.props.data;
    // fc_eventSources is the massaged data that fcCalendar wants.  
    // Need to to that tranformation here on the client vs the server, maybe via an Apollo method

    // this.setState({ eventSources });
    // console.log("Calendar: componentDidUpdate: eventSources = " + JSON.stringify(fcEventSources));
    this.updateEventSources(JSON.parse(fcEventSources));
  }

  // componentDidMount() {
  //   console.log("Calendar: componentDidMount: eventSources = " + JSON.stringify(this.props.data));
  // };

  updateEventSources = (eventSources) => {
    
    var eSources = eventSources;

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

const fcEventSourcesQuery = gql`
  query fcEventSourcesQuery {
    fcEventSources 
    },
  `;

// https://www.apollographql.com/docs/react/basics/queries.html
export default  graphql(fcEventSourcesQuery, {
  // ownProps are the props that are passed into the `ProfileWithData`
  // when it is used by a parent component
  // props: ({ ownProps, data: { fcEventSources } }) => ({
  //   loading: loading,
  //   // user: currentUser,
  //   eventSources: fcEventSources,

  //   // refetchUser: refetch,
  // }),
  // options: { 
  //   variables: { avatarSize: 100 },
  //   pollInterval: 20000 
  // },
  // skip: (ownProps) => !ownProps.authenticated,
})(Calendar);

// export default CalendarWithData;