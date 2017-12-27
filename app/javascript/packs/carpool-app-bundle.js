import ReactOnRails from 'react-on-rails';

import CarpoolApp from '../bundles/CarpoolApp/startup/CarpoolApp';
import Calendar from '../bundles/CarpoolApp/components/Calendar';

// This is how react_on_rails can see the Calendar in the browser.
ReactOnRails.register({
  CarpoolApp, Calendar
});
