import React from 'react';
import Calendar from '../components/Calendar';
import apolloClient from 'lib/apolloClient';
import { ApolloProvider, graphql } from 'react-apollo';

export default class CalendarApp extends React.Component {

  /**
   * @param props - Comes from your rails view.
   */
  constructor(props) {
    super(props);
    this.state = {
      eventSources: this.props.eventSources,
    };
  }

  render() {
    return (
      <ApolloProvider client={apolloClient}>
        <Calendar eventSources={this.state.eventSources}/>
      </ApolloProvider>
    );
  }
}