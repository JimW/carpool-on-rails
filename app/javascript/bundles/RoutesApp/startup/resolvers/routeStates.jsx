import gql from 'graphql-tag';

export const routeStates = {
  defaults: {
    routeFormState: {
      __typename: 'routeFormState',
      // feedData: {
        // __typename: 'FeedData', // Anyway to autodetect names from hash? Want to get rid of Apollo warnings for unnamed stuff
      // },
      crudType: '',
      routeId: null,
      feedData: '',
      startsAt: '',
      endsAt: '',
      currentLocation: '',
      currentDriver: '',
      currentPassengers: '',
      allDay: false,
    },
    networkStatus: {

    }
  },
  resolvers: { // Only needed for mutations
    // Mutation: {
    //   updateNewRouteFormState: (_, { startsAt, endsAt, isVisible, feedData }, { cache }) => {
    //     const query = gql`
    //       query GetNewRouteFormState {
    //         newRouteForm @client { 
    //           feedData,
    //           startsAt,
    //           endsAt,
    //           allDay,
    //           isVisible
    //         }
    //       }
    //     `;
    //     const previousState = cache.readQuery({ query })
    //     const data = {
    //       ...previousState,
    //       newRouteForm: {
    //         ...previousState.newRouteForm,
    //         startsAt: startsAt,
    //         endsAt: endsAt,
    //         isVisible: isVisible,
    //         feedData: feedData,
    //       },
    //     };
    //     cache.writeData({ data });

    //     // cache.writeData({ originalNewRouteFormState, data });
    //     // return null;
    //   },
    // },
    Mutation: {
      updateRouteFormState: (_, { crudType, routeId, startsAt, endsAt, feedData, currentLocation, currentDriver, currentPassengers }, { cache }) => {
        const query = gql`
          query GetRouteFormState {
            routeFormState @client { 
              crudType,
              routeId,
              startsAt,
              endsAt,
              allDay,
              feedData,
              currentLocation,
              currentDriver,
              currentPassengers,
            }
          }
        `;
        const previousState = cache.readQuery({ query })
        const data = {
          ...previousState,
          routeFormState: {
            ...previousState.routeFormState,
            routeId: routeId,
            startsAt: startsAt,
            endsAt: endsAt,
            feedData: feedData,
            currentLocation: currentLocation,
            currentDriver: currentDriver,
            currentPassengers: currentPassengers,
            crudType: crudType,
          },
        };
        cache.writeData({ data });

        // cache.writeData({ originalNewRouteFormState, data });
        // return null;
      },
    },

  }
};
