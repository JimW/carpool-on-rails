import PropTypes from 'prop-types';
import React, { Component } from 'react'
import { compose, graphql } from 'react-apollo';
import gql from 'graphql-tag';
import { Grid, Segment, Dimmer, Loader, Button, Checkbox, Form, Input, Radio, Select, TextArea, Message, Modal, Header, Icon, Visibility, TransitionablePortal } from 'semantic-ui-react'
// import { withApollo } from 'react-apollo';
import { getNewRouteFormState } from '../../graphql/newRouteForm'
import { createRouteMutation } from '../../graphql/newRouteForm'

class RouteForm extends Component {

  handleClose = () => this.props.showRouteForm(false)
  static propTypes = {
    feedData: PropTypes.object.isRequired,
    startsAt: PropTypes.string.isRequired,
    endsAt: PropTypes.string.isRequired,
  };

  constructor(props) {
    super(props);
    this.state = {
      startsAt: this.props.startsAt,
      endsAt: this.props.endsAt,
      allDay: false,
      
      allDrivers: this.props.feedData['activeDrivers'],
      allPassengers: this.props.feedData['activePassengers'],
      allLocations: this.props.feedData['locations'],

      currentLocation: '',
      currentDriver: '',
      currentPassengers: [''],

      newLocation: '',
      newDriver: '',
      newPassengers: [''],

      createRouteMutation: this.props.createRouteMutation,
      modalOpen: true
    };
  }

  handleChange = (e, { name, value }) => this.setState({ [name]: value })

  handleSubmit = () => {
    const { startsAt, endsAt, currentDriver, currentPassengers, currentLocation } = this.state
    var top = this;
    this.setState({ newDriver: currentDriver, newPassengers: currentPassengers, newLocation: currentLocation })
    createRoute(top, startsAt, endsAt, currentDriver, currentPassengers, currentLocation);
  }

  render() {
    return (
      <Modal
        open={this.state.modalOpen}
        onClose={this.handleClose}
        dimmer='inverted'
        size='large'
      >
        <Header icon='users' content='Route Assignments:' />
        <Modal.Content>
          {this.props.addNewEventToFullcalendar.loading ?
            <Dimmer enabled inverted>
              <Loader inverted content='Saving' />
            </Dimmer> : null
          }
          <p>Assign the pickup location, driver, and passengers</p>
          <Form size='large'>
            <Form.Group>
              <Form.Field control={Select} label='Location' upward name='currentLocation' defaultValue='' options={this.state.allLocations} placeholder='Select Location' onChange={this.handleChange} />
              <Form.Field control={Select} label='Driver' upward name='currentDriver' options={this.state.allDrivers} placeholder='Select Driver' onChange={this.handleChange} />
              <Form.Field control={Select} multiple upward label='Passengers' name='currentPassengers' options={this.state.allPassengers} placeholder='Select Passengers' onChange={this.handleChange} />
            </Form.Group>
          </Form>
        </Modal.Content>
        <Modal.Actions>
          <Button color='red' onClick={this.handleClose} inverted>
            <Icon name='cancel' /> Cancel
           </Button>
          <Button color='green' onClick={this.handleSubmit} inverted>
            <Icon name='checkmark' /> Save
           </Button>
        </Modal.Actions>
      </Modal>

    )
  }

}

// ________________________________ Apollo Calls ____________________________________________

function createRoute(top, startsAt, endsAt, driver, passengers, location) {

  top.props.createRouteMutation({
    variables: {
      startsAt: startsAt,
      endsAt: endsAt,
      driver: driver.toString(),
      passengers: passengers.toString(),
      location: location.toString(),
    }
  })
    .then(({ data }) => {
      var newFcRoute = JSON.parse(data.createRouteMutation);
      top.props.showRouteForm(false);
      top.props.addNewEventToFullcalendar(newFcRoute);
      // lastWorkingDate

      // # cookies.permanent[:last_working_date] = @route.starts_at.iso8601
      // # session[:last_route_id_edited] = @route.id # used to plant a Class to mark the event in the calendar, so the js can highlight the change and scroll to it.
    }).catch((error) => {
      console.log('there was an error sending the query', error);
    });
};

// ________________________________ Compose ____________________________________________

export default compose(
  graphql(createRouteMutation, { name: 'createRouteMutation', }),
  graphql(getNewRouteFormState, { name: 'getNewRouteFormState', }),
)(RouteForm);

  // https://www.apollographql.com/docs/react/basics/setup.html#graphql