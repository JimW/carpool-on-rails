import React, { Component } from 'react'
import PropTypes from 'prop-types';

import merge from 'lodash/merge';
import gql from 'graphql-tag';

// https://www.apollographql.com/docs
// https://github.com/apollographql/apollo-client/tree/master/packages/apollo-client-preset
import { ApolloProvider, graphql } from 'react-apollo';
// import ApolloClient from 'apollo-client'
import ApolloClient from 'apollo-client-preset'; // changes how it's loaded, with a few "reasonable" presets, maybe this was my issue..
import { HttpLink, InMemoryCache } from 'apollo-client-preset'

// https://www.apollographql.com/docs/link/links/state.html
import { ApolloLink } from 'apollo-link';
import { withClientState } from 'apollo-link-state';
import { createHttpLink } from "apollo-link-http";
import { setContext } from 'apollo-link-context';
import { onError } from "apollo-link-error";

// Resolvers
// import fullcalendar from '../resolvers/fullcalendar';

// Components
import Calendar from '../components/Calendar';

// This is the same cache you pass into new ApolloClient
// const cache = new InMemoryCache();

const httpLink = createHttpLink({
  uri: '/graphql',
  credentials: 'same-origin',
});

const authLink = setContext((_, { headers }) => {
  // return the headers to the context so httpLink can read them
  return {
    headers: {
      ...headers,
      "X-CSRF-Token": ReactOnRails.authenticityToken()
      // https://stackoverflow.com/questions/42723989/invalid-auth-token-with-rails-graphql-apollo-client#42724669
    }
  }
});
const client = new ApolloClient({
  link: authLink.concat(httpLink),
  // cache: cache,
  // cache: new InMemoryCache().restore({})
  cache: new InMemoryCache()
});

export default class CalendarApp extends Component {
  // static propTypes = {
  //   eventSources: PropTypes.string.isRequired, // this is passed from the Rails view
  // }
  /**
   * @param props - Comes from your rails view.
   */
  constructor(props) {
    super(props);
    // this.state = {
    //   eventSources: this.props.eventSources,
    // };
  }

  render() {
    return (
      <ApolloProvider client={client}>
        <Calendar/>
      </ApolloProvider>
    );
  }
}