import gql from 'graphql-tag';

export const getRouteQuery = gql`
query getRouteQuery ($id: Int!){
  route(id: $id) {
    id
    title
    starts_at
    ends_at
    locations {
      id
    }
    passengers {
      id
    }
    drivers {
      id
    }
  }
}
`;

export const allRoutesQuery = gql`
  query allRoutesQuery {
    allRoutes {
      id
      title
      drivers {
        id
      }
      passengers {
        id
      }
      locations {
        id
      }
    } 
  }
`;
// ________________________________ Client Mutations ____________________________________________

// when crudType = edit, it has to retrieve the route data and set as current State
// export const updateRouteTableViewState = gql`
//   mutation updateRouteTableViewState($currentRow: Int) {
//     updateRouteTableViewState(currentRow: $currentRow) @client {
//       currentRow,
//     }
//   }
// `;

