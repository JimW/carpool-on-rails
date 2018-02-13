import PropTypes from 'prop-types';
import React, { Component } from 'react'
import { compose, graphql } from 'react-apollo';
import gql from 'graphql-tag';
import { hasError } from 'apollo-client/core/ObservableQuery';
import { Table, Dimmer, Loader, Icon } from 'semantic-ui-react'
import { getRouteQuery } from '../graphql/routes'

class RouteTableRow extends Component {

  static propTypes = {
    id: PropTypes.number.isRequired
  };

  /**
   * @param props - Comes from your rails view.
   */
  constructor(props) {
    super(props);
  }

  render() {

    const { loading, error } = this.props.getRouteQuery;
    const route = this.props.getRouteQuery.route;

    if (loading) {
      return null;
    } else if (error) {
      return (
        <Icon name="warning sign" size='small' />
      )
    }

    return (
      <Table.Row>
        <Table.Cell>{route.id}</Table.Cell>
        <Table.Cell>{route.title}</Table.Cell>
      </Table.Row>
    )
  } // render

} // RouteTableRow

// ________________________________ Apollo Calls ____________________________________________


// ________________________________ Compose ____________________________________________

export default compose(
  graphql(getRouteQuery, {
    name: 'getRouteQuery'
  }),
)(RouteTableRow);