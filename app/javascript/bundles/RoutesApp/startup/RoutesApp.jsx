import React, { Component } from 'react'
import PropTypes from 'prop-types';
import merge from 'lodash/merge';
import gql from 'graphql-tag';
import { ApolloProvider, graphql } from 'react-apollo';
// import ApolloClient from 'apollo-client'
import ApolloClient from 'apollo-client-preset'; // changes how it's loaded, with a few "reasonable" presets, maybe this was my issue..
import { HttpLink, InMemoryCache } from 'apollo-client-preset'
import { ApolloLink } from 'apollo-link';
import { withClientState } from 'apollo-link-state';
import { createHttpLink } from "apollo-link-http";
import { setContext } from 'apollo-link-context';
import { onError } from "apollo-link-error";
// import RetryLink from "apollo-link-retry"

import RouteCalendar from '../components/RouteCalendar';

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

// https://www.youtube.com/watch?v=bv74TcKb1jw
// const retryLink = new RetryLink({
//   max: 10,
//   delay: 5000,
//   interval: (delay, count) => (count > 5 ? 10000 : delay),
// });

// const errorLink = onError(({graphqlErrors, networkError}) => {
//   if (graphqlErrors) sendToLogger(graphqlErrors); // https://sentry.io/pricing/
//   if (networkError) logoutUser();
// });
// const link = errorLink.concat(authLink.concat(httpLink));

const client = new ApolloClient({
  link: authLink.concat(httpLink),
  // cache: new InMemoryCache().restore({})
  cache: new InMemoryCache()
});

export default class RoutesApp extends Component {
  static propTypes = {
    eventSources: PropTypes.string.isRequired, // this is passed from the Rails view
  }
  /**
   * @param props - Comes from your rails view.
   */
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <ApolloProvider client={client}>
        <RouteCalendar eventSources={this.props.eventSources}/>
      </ApolloProvider>
    );
  }
}