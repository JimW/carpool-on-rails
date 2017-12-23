import ReactOnRails from 'react-on-rails';

import CalendarApp from '../bundles/Calendar/startup/CalendarApp';

// This is how react_on_rails can see the Calendar in the browser.
ReactOnRails.register({
  CalendarApp,
});
