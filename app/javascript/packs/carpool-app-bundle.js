import ReactOnRails from 'react-on-rails';

import CalendarApp from '../bundles/CalendarApp/startup/CalendarApp';
import RoutesApp from '../bundles/RoutesApp/startup/RoutesApp';
// import RouteForm from './RouteForm';
import RouteForm from '../bundles/RoutesApp/components/forms/RouteForm';

// This is how react_on_rails can see the Calendar in the browser.
ReactOnRails.register({
  CalendarApp, RoutesApp, RouteForm
});
