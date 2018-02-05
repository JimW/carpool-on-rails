import gql from 'graphql-tag';

export const getNetworkStatus = gql`
  query {
    getNetworkStatus @client {
      isConnected
    }
  }
`;

export const updateNetworkStatus = gql`
  mutation updateNetworkStatus($isConnected: Boolean) {
    updateNetworkStatus(isConnected: $isConnected) @client
  }
`;
