import PropTypes from 'prop-types';
import React, { Component } from 'react'
import { compose, graphql } from 'react-apollo';
import gql from 'graphql-tag';
import { hasError } from 'apollo-client/core/ObservableQuery';
import { Table, Dimmer, Loader } from 'semantic-ui-react'

import { allRoutesQuery } from '../graphql/routes'
import RouteTableRow from './RouteTableRow';

class RouteTableView extends Component {

  static propTypes = {
  };

  /**
   * @param props - Comes from your rails view.
   */
  constructor(props) {
    super(props);
    this.state = {

    };
  }

  render() {

    const { loading, error } = this.props.allRoutesQuery;
    const allRoutes = this.props.allRoutesQuery.allRoutes;

    if (loading) {
      return null;
    } else if (error) {
      return (
        <Icon name="warning sign" size='small' />
      )
    }
    // ______________________ Begin (props now loaded)

    var routeTableRowArray = allRoutes.reduce((accum, route) => {
      return accum.concat(
        <RouteTableRow
          key={route.id}
          id={Number(route.id)} />
      )
    }, [])

    if (allRoutes.length > 0) {
      return (
        <div>
          <Table celled>
            <Table.Header>
              <Table.Row>
                <Table.HeaderCell>Time</Table.HeaderCell>
                <Table.HeaderCell>Title</Table.HeaderCell>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {routeTableRowArray}
            </Table.Body>
          </Table>
        </div >
      );
    }

    return null;

  } // render

} // RouteTableView

// ________________________________ Apollo Calls ____________________________________________

// ________________________________ Compose ____________________________________________

// const getRouteTableViewState = gql`
//   query {
//     routeTableViewState @client { 
//       currentRow,
//     }
//   }
// `;

// const updateRouteTableViewState = gql`
//   mutation updateRouteTableViewState($currentRow: Int) {
//     updateRouteTableViewState(currentRow: $currentRow) @client {
//       currentRow,
//     }
//   }
// `;

export default compose(
  graphql(allRoutesQuery, {
    name: 'allRoutesQuery',
  }),
)(RouteTableView);