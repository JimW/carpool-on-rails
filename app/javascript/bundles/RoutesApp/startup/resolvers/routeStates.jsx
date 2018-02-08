import gql from 'graphql-tag';

export const routeStates = {
  defaults: {
    routeForm: {
      __typename: 'routeForm',
      // feedData: {
        // __typename: 'FeedData', // Anyway to autodetect names from hash? Want to get rid of Apollo warnings for unnamed stuff
      // },
      crudType: '',
      routeId: null,
      feedData: '',
      isVisible: false,
      startsAt: '',
      endsAt: '',
      location: '',
      driver: '',
      passengers: '',
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
      updateRouteFormState: (_, { crudType, routeId, startsAt, endsAt, isVisible, feedData, location, driver, passengers }, { cache }) => {
        const query = gql`
          query GetRouteFormState {
            routeForm @client { 
              crudType,
              routeId,
              startsAt,
              endsAt,
              allDay,
              isVisible,
              feedData,
              location,
              driver,
              passengers,
            }
          }
        `;
        const previousState = cache.readQuery({ query })
        const data = {
          ...previousState,
          routeForm: {
            ...previousState.routeForm,
            routeId: routeId,
            startsAt: startsAt,
            endsAt: endsAt,
            isVisible: isVisible,
            feedData: feedData,
            location: location,
            driver: driver,
            passengers: passengers,
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
