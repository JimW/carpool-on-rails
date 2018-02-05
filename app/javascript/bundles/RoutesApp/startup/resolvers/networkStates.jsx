export const networkStates = {
  defaults: {
    networkStatus: {
      __typename: 'NetworkStatus',
      isConnected: true,
    },
  },
  resolvers: {
    Mutation: {
      updateNetworkStatus: (_, { isConnected }, { cache }) => {
        const data = {
          networkStatus: { isConnected },
        };
        cache.writeData({ data });
      },
    },
    // Query: {
    //   getNetworkStatus: (_, { isConnected }, { cache }) => {
    //     const data = {
    //       networkStatus: { isConnected },
    //     };
    //     // cache.writeData({ data });
    //   },
    // }
  }
};