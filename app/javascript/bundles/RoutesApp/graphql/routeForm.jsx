import gql from 'graphql-tag';

export const getRouteFormState = gql`
  query {
    routeForm @client { 
      crudType,
      routeId,
      feedData,
      startsAt,
      endsAt,
      allDay,
      isVisible,
      driver,
      location,
      passengers,
    }
  }
`;
// ________________________________ Client Mutations ____________________________________________

// when crudType = edit, it has to retrieve the route data and set as current State
export const updateRouteFormState = gql`
  mutation updateRouteFormState($crudType: String!, $routeId: Int, $startsAt: String!, $endsAt: String!, $isVisible: Boolean, $feedData: feedData, $location: String, $driver: String, $passengers: String) {
    updateRouteFormState(crudType: $crudType, routeId: $routeId, startsAt: $startsAt, endsAt: $endsAt, isVisible: $isVisible, feedData: $feedData, crudType: $crudType, location: $location, driver: $driver, passengers: $passengers) @client {
      crudType,
      routeId,
      feedData,
      startsAt,
      endsAt,
      allDay,
      isVisible,
      crudType,
      location,
      driver,
      passengers
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