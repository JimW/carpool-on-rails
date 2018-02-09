import gql from 'graphql-tag';

export const getRouteFormState = gql`
  query {
    routeFormState @client { 
      crudType,
      routeId,
      feedData,
      startsAt,
      endsAt,
      allDay,
      currentDriver,
      currentLocation,
      currentPassengers,
    }
  }
`;

export const newRouteFeedDataQuery = gql`
  query newRouteFeedDataQuery {
    newRouteFeedData 
  }
`;
// ________________________________ Client Mutations ____________________________________________

// when crudType = edit, it has to retrieve the route data and set as current State
export const updateRouteFormState = gql`
  mutation updateRouteFormState($crudType: String!, $routeId: Int, $startsAt: String!, $endsAt: String!, $feedData: feedData, $currentLocation: String, $currentDriver: String, $currentPassengers: String) {
    updateRouteFormState(crudType: $crudType, routeId: $routeId, startsAt: $startsAt, endsAt: $endsAt, feedData: $feedData, crudType: $crudType, currentLocation: $currentLocation, currentDriver: $currentDriver, currentPassengers: $currentPassengers) @client {
      crudType,
      routeId,
      feedData,
      startsAt,
      endsAt,
      allDay,
      crudType,
      currentDriver,
      currentLocation,
      currentPassengers,
    }
  }
`;

// ________________________________ Server Mutations ____________________________________________

export const createRouteMutation = gql`
    mutation createRouteMutation($startsAt: String!, $endsAt: String!, $driver: String, $passengers: String, $location: String,) {
      createRouteMutation(startsAt: $startsAt, endsAt: $endsAt, driver: $driver, passengers: $passengers, location: $location)
    }
  `;

  export const updateRouteMutation = gql`
    mutation updateRouteMutation($id: Int!, $startsAt: String!, $endsAt: String!, $driver: String, $passengers: String, $location: String,) {
      updateRouteMutation(id: $id, startsAt: $startsAt, endsAt: $endsAt, driver: $driver, passengers: $passengers, location: $location)
    }
  `;