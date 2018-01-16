import ReactOnRails from 'react-on-rails';

import CalendarApp from '../bundles/CalendarApp/startup/CalendarApp';
import RoutesApp from '../bundles/RoutesApp/startup/RoutesApp';

// This is how react_on_rails can see the Calendar in the browser.
ReactOnRails.register({
  CalendarApp, RoutesApp
});
