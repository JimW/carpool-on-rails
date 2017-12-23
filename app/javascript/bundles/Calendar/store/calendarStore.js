import { createStore } from 'redux';
import calendarReducer from '../reducers/calendarReducer';

const configureStore = (railsProps) => (
  createStore(calendarReducer, railsProps)
);

export default configureStore;
