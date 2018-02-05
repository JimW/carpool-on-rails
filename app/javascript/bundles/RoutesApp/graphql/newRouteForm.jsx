import gql from 'graphql-tag';

// ________________________________ Client Queries ____________________________________________

export const getNewRouteFormState = gql`
  query {
    newRouteForm @client { 
      feedData,
      startsAt,
      endsAt,
      allDay,
      isVisible
    }
  }
`;

// ________________________________ Client Mutations ____________________________________________

export const updateNewRouteFormState = gql`
  mutation updateNewRouteFormState($startsAt: String!, $endsAt: String!, $isVisible: Boolean, $feedData: feedData) {
    updateNewRouteFormState(startsAt: $startsAt, endsAt: $endsAt, isVisible: $isVisible, feedData: $feedData) @client {
      feedData,
      startsAt,
      endsAt,
      allDay,
      isVisible
    }
  }
`;

// ________________________________ Server Mutations ____________________________________________

export const createRouteMutation = gql`
    mutation createRouteMutation($startsAt: String!, $endsAt: String!, $driver: String, $passengers: String, $location: String,) {
      createRouteMutation(startsAt: $startsAt, endsAt: $endsAt, driver: $driver, passengers: $passengers, location: $location)
    }
  `;