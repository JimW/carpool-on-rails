import ReactOnRails from 'react-on-rails';

import CalendarApp from '../bundles/CalendarApp/startup/CalendarApp';
import RoutesApp from '../bundles/RoutesApp/startup/RoutesApp';
import RouteForm from '../bundles/RoutesApp/components/forms/RouteForm';
import RouteTableView from '../bundles/RoutesApp/components/RouteTableView';
import RouteTableRow from '../bundles/RoutesApp/components/RouteTableRow';

// This is how react_on_rails can see the Calendar in the browser.
ReactOnRails.register({
  CalendarApp, RoutesApp, RouteForm, RouteTableView, RouteTableRow
});
