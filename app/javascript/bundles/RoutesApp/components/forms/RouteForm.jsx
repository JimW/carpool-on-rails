import PropTypes from 'prop-types';
import React, { Component } from 'react'
import { Icon } from 'semantic-ui-react'
import { Dropdown } from 'semantic-ui-react'
import { Button, Checkbox, Form, Input, Radio, Select, TextArea, Message } from 'semantic-ui-react'

class RouteForm extends Component {

  static propTypes = {
    feedData: PropTypes.object.isRequired,
    startsAt: PropTypes.object.isRequired,
    endsAt: PropTypes.object.isRequired,
  };

  constructor(props) {
    super(props);
    this.state = {
      startsAt: '',
      endsAt: '',
      allDay: false,
      available_drivers: this.props.feedData['activeDrivers'],
      available_passengers: this.props.feedData['activePassengers'],
      newDriver: '',
      newPassengers: [''],
      submittedNewDriver: '',
      submittedNewPassengers: ['']
    };
  }

  handleChange = (e, { name, value }) => this.setState({ [name]: value })

  handleSubmit = () => {
    const { newDriver, newPassengers } = this.state

    this.setState({ submittedNewDriver: newDriver, submittedNewPassengers: newPassengers })
    // alert('Your passenges are: ' + this.state.submittedNewPassengers);
  }

  render() {
    return (
      <Form onSubmit={this.handleSubmit}>>
        <Form.Group unstackable widths='equal'>
          <Form.Field control={Select} label='Driver' name='newDriver' options={this.state.available_drivers} placeholder='Select Driver' onChange={this.handleChange} />
          <Form.Field control={Select} multiple label='Passengers' name='newPassengers' options={this.state.available_passengers} placeholder='Select Passengers' onChange={this.handleChange} />
          <Form.Button content='Submit' />
        </Form.Group>

      </Form>
    )
  }
}
export default RouteForm
