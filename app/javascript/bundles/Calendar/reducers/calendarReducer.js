import { combineReducers } from 'redux';
import { CALENDAR_NAME_UPDATE } from '../constants/calendarConstants';
import { CALENDAR_EVENT_SOURCES_UPDATE } from '../constants/calendarConstants';

const name = (state = '', action) => {
  switch (action.type) {
    case CALENDAR_NAME_UPDATE:
      return action.text;
    default:
      return state;
  }
};

const eventSources = (state = '', action) => {
  switch (action.type) {
    case CALENDAR_EVENT_SOURCES_UPDATE:
      return action.text;
    default:
      return state;
  }
};
const calendarReducer = combineReducers({
   name,
   eventSources 
  });

export default calendarReducer;
