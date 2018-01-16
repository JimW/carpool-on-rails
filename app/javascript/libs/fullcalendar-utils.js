// Add in the fullcalendar formatting for each type of route
export function assignFullCalendarStyle(category, obj) {
  var colorScheme = {
    instance: {
      color: '#D4FFD7',
      textColor: '#524B3E',
      borderColor: '#93CC97'
    },
    modified_instance: {
      color: '#F0FFB6',
      textColor: '#35352E',
      borderColor: '#50DA59'
    },
    special: {
      color: '#F9E0CA',
      textColor: '#503A0D',
      borderColor: '#E4AFAF'
    },
    template: {
      color: '#D4FFD7',
      textColor: '#93CC97',
      borderColor: '#524B3E'
    }
  }
  return Object.assign(obj, colorScheme[category]);
}