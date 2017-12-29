import React, { Component } from 'react'
import merge from 'lodash/merge';
import gql from 'graphql-tag';

// https://www.apollographql.com/docs
import { ApolloProvider, graphql } from 'react-apollo';
import { ApolloClient, HttpLink, InMemoryCache } from 'apollo-client-preset';

// https://www.apollographql.com/docs/link/links/state.html
import { ApolloLink } from 'apollo-link';
import { withClientState } from 'apollo-link-state';
import { createHttpLink } from "apollo-link-http";
import { setContext } from 'apollo-link-context';
import { onError } from "apollo-link-error";

// Resolvers
import fullcalendar from '../resolvers/fullcalendar';

// import client from 'lib/apolloClient';
// import { defaults, resolvers } from '../resolvers/carpoolApp';

// Components
import Calendar from '../components/Calendar';

// This is the same cache you pass into new ApolloClient
const cache = new InMemoryCache();

// Using this for now while we stick to cookies
const httpLink = createHttpLink({
  uri: '/graphql',
});
  // credentials: 'same-origin'

const client = new ApolloClient({
  // By default, this client will send queries to the
  //  `/graphql` endpoint on the same host
  link: httpLink,
  cache: cache,
});

export default class CalendarApp extends Component {

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
      <ApolloProvider client={client}>
        <Calendar eventSources={this.state.eventSources}/>
      </ApolloProvider>
    );
  }
}









    // // import { graphql } from 'react-apollo';
// // import gql from 'graphql-tag';

// // function graphqlQ() {
// //   return graphql(gql`
// //   query CalendarAppQuery {
// //     fc_eventSources {}
// //   }
// // `)
// // }

// We use the gql tag to parse our query string into a query document
// const CurrentUserForLayout = gql`
//   query CurrentUserForLayout {
//     currentUser {
//       login
//       avatar_url
//     }
//   }
// `;

// const ProfileWithData = graphql(CurrentUserForLayout)(Profile);



// const UPDATE_NETWORK_STATUS = gql`
//   mutation updateNetworkStatus($isConnected: Boolean) {
//     updateNetworkStatus(isConnected: $isConnected) @client
//   }
// `;


// export default graphql(QUERY_ALL_EVENTS) (Calendar)

// const Calendar = graphql(QUERY_ALL_EVENTS, {
//   props: ({ data: { networkStatus, eventSources } }) => {
//     if (data.loading) {
//       return { loading: data.loading };
//     }
//     if (data.error) {
//       return { error: data.error };
//     }
//     return {
//       loading: false,
//       networkStatus,
//       eventSources,
//     };
//   },
// })(Calendar);

// export default Calendar

// export default Calendar;
