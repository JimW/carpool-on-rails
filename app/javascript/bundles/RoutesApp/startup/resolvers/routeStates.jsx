import gql from 'graphql-tag';

export const routeStates = {
  defaults: {
    newRouteForm: {
      __typename: 'NewRouteForm',
      // feedData: {
      // __typename: 'FeedData', // Anyway to autodetect names from hash?

      // },
      feedData: '',
      startsAt: '',
      endsAt: '',
      allDay: false,
      isVisible: false,
    },
    networkStatus: {

    }
  },
  resolvers: { // Only needed for mutations
    Mutation: {
      updateRouteFormVisibility: (_, { isVisible }, { cache }) => {
        const data = {
          newRouteForm: { isVisible },
        };
        cache.writeData({ data });
        return null;
      },
    },
    Mutation: {
      updateNewRouteFormState: (_, { startsAt, endsAt, isVisible, feedData }, { cache }) => {
        const query = gql`
          query GetNewRouteFormState {
            newRouteForm @client { 
              feedData,
              startsAt,
              endsAt,
              allDay,
              isVisible
            }
          }
        `;
        const previousState = cache.readQuery({ query })
        const data = {
          ...previousState,
          newRouteForm: {
            ...previousState.newRouteForm,
            startsAt: startsAt,
            endsAt: endsAt,
            isVisible: isVisible,
            feedData: feedData,
          },
        };
        cache.writeData({ data });

        // cache.writeData({ originalNewRouteFormState, data });
        // return null;
      },
    },
  }
};
