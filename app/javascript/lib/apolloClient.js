import { ApolloClient, HttpLink, InMemoryCache } from 'apollo-client-preset';

const apolloClient = new ApolloClient({
  // By default, this client will send queries to the
  //  `/graphql` endpoint on the same host
  link: new HttpLink(),
  cache: new InMemoryCache()
});

export default apolloClient;
