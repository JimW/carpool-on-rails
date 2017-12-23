/* eslint-disable import/prefer-default-export */

import { CALENDAR_NAME_UPDATE } from '../constants/calendarConstants';
import { CALENDAR_EVENT_SOURCES_UPDATE } from '../constants/calendarConstants';

export const updateEventSources = (eventsList) => ({
  type: CALENDAR_EVENT_SOURCES_UPDATE,
  text,
});

export const updateName = (text) => ({
  type: CALENDAR_NAME_UPDATE,
  text,
});
